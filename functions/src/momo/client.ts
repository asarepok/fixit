import {randomUUID} from "crypto";
import {MOMO_BASE_URL, MOMO_CURRENCY, MOMO_TARGET_ENVIRONMENT} from "./config";

// A thin wrapper around the two MTN MoMo products this app uses:
// Collections (charging a customer) and Disbursements (paying an
// artisan, or refunding a customer). Everything above this file works
// with plain uid/amount/phoneNumber values, this is the only place that
// knows MoMo's actual request shapes.

export type MomoProduct = "collection" | "disbursement";

export interface MomoCredentials {
  subscriptionKey: string;
  apiUser: string;
  apiKey: string;
}

async function getAccessToken(
  product: MomoProduct,
  creds: MomoCredentials
): Promise<string> {
  const basicAuth = Buffer.from(`${creds.apiUser}:${creds.apiKey}`).toString(
    "base64"
  );

  const response = await fetch(`${MOMO_BASE_URL}/${product}/token/`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Ocp-Apim-Subscription-Key": creds.subscriptionKey,
    },
  });

  if (!response.ok) {
    throw new Error(`MoMo ${product} token request failed: ${response.status}`);
  }

  const data = (await response.json()) as {access_token: string};
  return data.access_token;
}

interface MomoMoneyMoveParams {
  amount: number;
  phoneNumber: string;
  externalId: string;
  payerMessage: string;
  creds: MomoCredentials;
}

/** Charges a customer's MoMo wallet. Returns MoMo's reference id, check
 * its status with getRequestToPayStatus, it does not resolve immediately. */
export async function requestToPay(
  params: MomoMoneyMoveParams
): Promise<string> {
  const token = await getAccessToken("collection", params.creds);
  const referenceId = randomUUID();

  const response = await fetch(`${MOMO_BASE_URL}/collection/v1_0/requesttopay`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
      "X-Reference-Id": referenceId,
      "X-Target-Environment": MOMO_TARGET_ENVIRONMENT,
      "Ocp-Apim-Subscription-Key": params.creds.subscriptionKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      amount: params.amount.toString(),
      currency: MOMO_CURRENCY,
      externalId: params.externalId,
      payer: {partyIdType: "MSISDN", partyId: params.phoneNumber},
      payerMessage: params.payerMessage,
      payeeNote: params.payerMessage,
    }),
  });

  if (response.status !== 202) {
    throw new Error(`MoMo requestToPay failed: ${response.status}`);
  }

  return referenceId;
}

export async function getRequestToPayStatus(
  referenceId: string,
  creds: MomoCredentials
): Promise<string> {
  const token = await getAccessToken("collection", creds);

  const response = await fetch(
    `${MOMO_BASE_URL}/collection/v1_0/requesttopay/${referenceId}`,
    {
      headers: {
        "Authorization": `Bearer ${token}`,
        "X-Target-Environment": MOMO_TARGET_ENVIRONMENT,
        "Ocp-Apim-Subscription-Key": creds.subscriptionKey,
      },
    }
  );

  if (!response.ok) {
    throw new Error(
      `MoMo requestToPay status check failed: ${response.status}`
    );
  }

  const data = (await response.json()) as {status: string};
  return data.status; // PENDING | SUCCESSFUL | FAILED
}

/** Pays money out, to an artisan on release, or to a customer on refund.
 * Returns MoMo's reference id, check with getTransferStatus. */
export async function transfer(params: MomoMoneyMoveParams): Promise<string> {
  const token = await getAccessToken("disbursement", params.creds);
  const referenceId = randomUUID();

  const response = await fetch(`${MOMO_BASE_URL}/disbursement/v1_0/transfer`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
      "X-Reference-Id": referenceId,
      "X-Target-Environment": MOMO_TARGET_ENVIRONMENT,
      "Ocp-Apim-Subscription-Key": params.creds.subscriptionKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      amount: params.amount.toString(),
      currency: MOMO_CURRENCY,
      externalId: params.externalId,
      payee: {partyIdType: "MSISDN", partyId: params.phoneNumber},
      payerMessage: params.payerMessage,
      payeeNote: params.payerMessage,
    }),
  });

  if (response.status !== 202) {
    throw new Error(`MoMo transfer failed: ${response.status}`);
  }

  return referenceId;
}

export async function getTransferStatus(
  referenceId: string,
  creds: MomoCredentials
): Promise<string> {
  const token = await getAccessToken("disbursement", creds);

  const response = await fetch(
    `${MOMO_BASE_URL}/disbursement/v1_0/transfer/${referenceId}`,
    {
      headers: {
        "Authorization": `Bearer ${token}`,
        "X-Target-Environment": MOMO_TARGET_ENVIRONMENT,
        "Ocp-Apim-Subscription-Key": creds.subscriptionKey,
      },
    }
  );

  if (!response.ok) {
    throw new Error(`MoMo transfer status check failed: ${response.status}`);
  }

  const data = (await response.json()) as {status: string};
  return data.status;
}
