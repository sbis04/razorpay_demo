function checkout(optionsStr) {
    var options = JSON.parse(optionsStr);
    var isProcessing = true;
    options["modal"] = {
        "escape": false,
        "ondismiss": function () {
            if (isProcessing) {
                let responseStr = JSON.stringify({
                    'isSuccessful': false,
                    'errorCode': 'MODAL_DISMISSED',
                    'errorDescription': 'Razorpay payment modal dismissed'
                });
                handleWebCheckoutResponse(responseStr);
            }
        }
    };
    options.handler = function (response) {
        let responseStr = JSON.stringify({
            'isSuccessful': true,
            'orderId': response.razorpay_order_id,
            'paymentId': response.razorpay_payment_id,
            'signature': response.razorpay_signature
        });
        isProcessing = false;
        handleWebCheckoutResponse(responseStr);
    }
    let razorpay = new Razorpay(options);
    razorpay.on('payment.failed', function (response) {
        let responseStr = JSON.stringify({
            'isSuccessful': false,
            'errorCode': response.error.code,
            'errorDescription': response.error.description,
        });
        isProcessing = false;
        handleWebCheckoutResponse(responseStr);
    });
    razorpay.open();
}