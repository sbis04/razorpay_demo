function checkout(optionsStr) {
    var options = JSON.parse(optionsStr);
    var isProcessing = true;
    options["modal"] = {
        "escape": false,
        // Handle if the dialog is dismissed
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
    // Handling successful transaction
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
    // Handling failed transaction
    razorpay.on('payment.failed', function (response) {
        let responseStr = JSON.stringify({
            'isSuccessful': false,
            'errorCode': response.error.code,
            'errorDescription': response.error.description,
        });
        isProcessing = false;
        handleWebCheckoutResponse(responseStr);
    });
    // Start checkout process
    razorpay.open();
}