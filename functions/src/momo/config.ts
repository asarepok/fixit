import {defineSecret} from "firebase-functions/params";

// Six secrets total: MTN MoMo has separate products for charging a
// customer (Collections) and paying out an artisan (Disbursements), and
// each product needs its own subscription key plus its own API user/key
// pair. Set these with `firebase functions:secrets:set NAME`, run from
// your own terminal so the value never ends up anywhere but Secret
// Manager, never hardcode them here.
export const momoCollectionSubscriptionKey = defineSecret(
  "MOMO_COLLECTION_SUBSCRIPTION_KEY"
);
export const momoCollectionApiUser = defineSecret("MOMO_COLLECTION_API_USER");
export const momoCollectionApiKey = defineSecret("MOMO_COLLECTION_API_KEY");

export const momoDisbursementSubscriptionKey = defineSecret(
  "MOMO_DISBURSEMENT_SUBSCRIPTION_KEY"
);
export const momoDisbursementApiUser = defineSecret(
  "MOMO_DISBURSEMENT_API_USER"
);
export const momoDisbursementApiKey = defineSecret(
  "MOMO_DISBURSEMENT_API_KEY"
);

// Sandbox only supports EUR and this base URL. Moving to production means
// swapping both of these plus every secret above for live MTN-issued
// values, nothing else in this file changes.
export const MOMO_BASE_URL = "https://sandbox.momodeveloper.mtn.com";
export const MOMO_TARGET_ENVIRONMENT = "sandbox";
export const MOMO_CURRENCY = "EUR";
