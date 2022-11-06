const functions = require("firebase-functions");
const Razorpay = require("razorpay");
const crypto = require("crypto");

const instance = new Razorpay({
  key_id: functions.config().razorpay.key_id,
  key_secret: functions.config().razorpay.key_secret,
});

exports.createOrder = functions.https.onCall(async (data, context) => {
  try {
    const order = await instance.orders.create({
      amount: data.amount,
      currency: data.currency,
      receipt: data.receipt,
      notes: {
        info: data.description,
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
