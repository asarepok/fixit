import {defineSecret} from "firebase-functions/params";

// One secret instead of MoMo's six. Paystack uses a single secret key for
// every server-side call this app makes: initializing a charge, verifying
// it, creating a transfer recipient, sending a payout, and refunding. Set
// it with `firebase functions:secrets:set PAYSTACK_SECRET_KEY`, run from
// your own terminal so the value never ends up anywhere but Secret
// Manager, never hardcode it here.
export const paystackSecretKey = defineSecret("PAYSTACK_SECRET_KEY");

export const PAYSTACK_BASE_URL = "https://api.paystack.co";

// Ghana Cedis. Paystack wants every amount in the smallest unit (pesewas),
// see toPesewas in client.ts, this constant is just the currency code sent
// alongside those amounts.
export const PAYSTACK_CURRENCY = "GHS";
