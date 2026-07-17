import * as admin from "firebase-admin";

admin.initializeApp();

export {initiatePaystackPayment} from "./payments/initiatePaystackPayment";
export {checkPaystackPaymentStatus} from "./payments/checkPaystackPaymentStatus";
export {releaseEscrowToArtisan} from "./payments/releaseEscrowToArtisan";
export {refundEscrow} from "./payments/refundEscrow";
export {paystackWebhook} from "./payments/paystackWebhook";
export {submitReview} from "./reviews/submitReview";
