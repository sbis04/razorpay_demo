const functions = require("firebase-functions");
const Razorpay = require("razorpay");
const crypto = require("crypto");

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: functions.config().razorpay.key_id,
  key_secret: functions.config().razorpay.key_secret,
});

// Function for creating an order required for processing
// the checkout
exports.createOrder = functions.https.onCall(async (data, context) => {
  try {
    const order = await razorpay.orders.create({
      amount: data.amount,
      currency: data.currency,
      receipt: data.receipt,
      notes: {
        description: data.description,
      },
    });

    return order;
  } catch (err) {
    console.error(`${err}`);
    throw new functions.https.HttpsError(
        "aborted",
        "Could not create the order",
    );
  }
});

// Function for verifying the signature after the checkout is done
exports.verifySignature = functions.https.onCall(async (data, context) => {
  const hmac = crypto.createHmac(
      "sha256",
      functions.config().razorpay.key_secret,
  );
  hmac.update(data.orderId + "|" + data.paymentId);
  const generatedSignature = hmac.digest("hex");
  const isSignatureValid = generatedSignature == data.signature;
  return isSignatureValid;
});
