import {PAYSTACK_BASE_URL, PAYSTACK_CURRENCY} from "./config";

// A thin wrapper around the parts of the Paystack API this app uses:
// starting a charge, checking whether it went through, registering a
// payout recipient, sending a payout, and refunding. Everything above
// this file works with plain amount/email/phoneNumber values, this is the
// only place that knows Paystack's actual request and response shapes.

function toPesewas(amountInCedis: number): number {
  return Math.round(amountInCedis * 100);
}

interface PaystackEnvelope<T> {
  status: boolean;
  message: string;
  data: T;
}

async function paystackFetch<T>(
  path: string,
  secretKey: string,
  init?: RequestInit
): Promise<T> {
  const response = await fetch(`${PAYSTACK_BASE_URL}${path}`, {
    ...init,
    headers: {
      "Authorization": `Bearer ${secretKey}`,
      "Content-Type": "application/json",
      ...(init?.headers as Record<string, string> | undefined),
    },
  });

  const body = (await response.json()) as PaystackEnvelope<T>;

  if (!response.ok || body.status === false) {
    throw new Error(`Paystack ${path} failed: ${body.message ?? response.status}`);
  }

  return body.data;
}

interface InitializeParams {
  amount: number;
  email: string;
  reference: string;
  secretKey: string;
}

// Paystack redirects the checkout webview here once the customer finishes
// (success, failure, or cancel), the app watches for any navigation to
// this URL to know the checkout closed and it's time to check the real
// status, the page itself never needs to actually load or exist.
export const PAYSTACK_CALLBACK_URL = "https://fixit-74c45.web.app/payment-callback";

/** Starts a charge. Returns the authorization URL, Paystack's actual
 * hosted checkout page, which the app opens in a plain webview. This is
 * what supports every channel (mobile money, card, bank transfer, ...),
 * unlike paystack_flutter_sdk's native checkout UI, which turned out to
 * only support cards. This function never sees a card number or a mobile
 * money PIN, that only ever happens on Paystack's own page. */
export async function initializeTransaction(
  params: InitializeParams
): Promise<{authorizationUrl: string; reference: string}> {
  const data = await paystackFetch<{
    authorization_url: string;
    reference: string;
  }>("/transaction/initialize", params.secretKey, {
    method: "POST",
    body: JSON.stringify({
      amount: toPesewas(params.amount),
      email: params.email,
      reference: params.reference,
      currency: PAYSTACK_CURRENCY,
      callback_url: PAYSTACK_CALLBACK_URL,
    }),
  });

  return {authorizationUrl: data.authorization_url, reference: data.reference};
}

/** The only thing ever trusted to say a charge actually succeeded, never
 * the client's own report of what the checkout UI showed it. Returns
 * Paystack's own status string, success | failed | abandoned | pending
 * (treat anything that isn't success/failed/abandoned as still pending). */
export async function verifyTransaction(
  reference: string,
  secretKey: string
): Promise<string> {
  const data = await paystackFetch<{status: string}>(
    `/transaction/verify/${encodeURIComponent(reference)}`,
    secretKey
  );
  return data.status;
}

let cachedMomoBankCodes: Record<string, string> | null = null;

/** Paystack identifies a mobile money network by a "bank code" that has to
 * be looked up rather than guessed, this fetches the list once per cold
 * start and keeps it around, keyed by lowercase network name (mtn,
 * vodafone, airteltigo, ...) since that's simpler for the rest of this app
 * to work with than Paystack's raw codes. */
async function resolveMomoBankCode(
  network: string,
  secretKey: string
): Promise<string> {
  if (!cachedMomoBankCodes) {
    const banks = await paystackFetch<{name: string; code: string}[]>(
      `/bank?currency=${PAYSTACK_CURRENCY}&type=mobile_money`,
      secretKey
    );

    cachedMomoBankCodes = {};
    for (const bank of banks) {
      cachedMomoBankCodes[bank.name.toLowerCase()] = bank.code;
    }
  }

  const match = Object.entries(cachedMomoBankCodes).find(([name]) =>
    name.includes(network.toLowerCase())
  );
  if (!match) {
    throw new Error(`No Paystack mobile money network matches "${network}".`);
  }
  return match[1];
}

interface RecipientParams {
  name: string;
  phoneNumber: string;
  network: string;
  secretKey: string;
}

/** The app's own phone validator accepts either local (0XXXXXXXXX) or
 * international (+233XXXXXXXXX) input and stores whatever was typed as
 * is, but Paystack's Ghana mobile money account_number needs the local,
 * leading-zero form specifically, it rejects the +233 form as an invalid
 * account number. Normalizes either stored shape into that one form. */
function toLocalGhanaFormat(phoneNumber: string): string {
  const digits = phoneNumber.replace(/[\s-]/g, "");
  if (/^0\d{9}$/.test(digits)) return digits;
  if (/^\+233\d{9}$/.test(digits)) return "0" + digits.slice(4);
  if (/^233\d{9}$/.test(digits)) return "0" + digits.slice(3);
  throw new Error(`"${phoneNumber}" isn't a recognizable Ghana phone number.`);
}

/** Registers who a payout goes to. Paystack needs this as a separate,
 * one-time step before it will send money to someone, unlike MoMo's
 * disbursement API which just took a phone number directly on every
 * transfer. Returns a recipient code, worth caching on their user doc to
 * reuse on future payouts instead of recreating one every time, see
 * releaseEscrowToArtisan. */
export async function createTransferRecipient(
  params: RecipientParams
): Promise<string> {
  const bankCode = await resolveMomoBankCode(params.network, params.secretKey);

  const data = await paystackFetch<{recipient_code: string}>(
    "/transferrecipient",
    params.secretKey,
    {
      method: "POST",
      body: JSON.stringify({
        type: "mobile_money",
        name: params.name,
        account_number: toLocalGhanaFormat(params.phoneNumber),
        bank_code: bankCode,
        currency: PAYSTACK_CURRENCY,
      }),
    }
  );

  return data.recipient_code;
}

interface TransferParams {
  amount: number;
  recipientCode: string;
  reason: string;
  secretKey: string;
}

/** Pays an artisan out on release. Returns Paystack's transfer reference,
 * check it with verifyTransferStatus. */
export async function initiateTransfer(
  params: TransferParams
): Promise<string> {
  const data = await paystackFetch<{reference: string}>(
    "/transfer",
    params.secretKey,
    {
      method: "POST",
      body: JSON.stringify({
        source: "balance",
        amount: toPesewas(params.amount),
        recipient: params.recipientCode,
        reason: params.reason,
      }),
    }
  );

  return data.reference;
}

export async function verifyTransferStatus(
  reference: string,
  secretKey: string
): Promise<string> {
  const data = await paystackFetch<{status: string}>(
    `/transfer/verify/${encodeURIComponent(reference)}`,
    secretKey
  );
  return data.status;
}

/** Reverses a charge back to whoever paid it, a real refund against the
 * original transaction, unlike MoMo's version of this which was really
 * just a second, separate transfer pretending to be a refund. */
export async function refundTransaction(
  transactionReference: string,
  secretKey: string
): Promise<void> {
  await paystackFetch<unknown>("/refund", secretKey, {
    method: "POST",
    body: JSON.stringify({transaction: transactionReference}),
  });
}
