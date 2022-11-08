function checkout(optionsStr) {
    var options = JSON.parse(optionsStr);
    var status;
    options["modal"] = {
        "escape": false,
        "ondismiss": function () {
            window.sessionStorage.setItem('razorpayStatus', 'FAILED');
            if (!window.sessionStorage['errorCode']) {
                window.sessionStorage.setItem('errorCode', 'MODAL_DISMISSED');
                window.sessionStorage.setItem('errorDescription', 'Razorpay payment modal dismissed');
            }
        }
    };
    options.handler = function (response) {
        window.sessionStorage.setItem('razorpayStatus', 'SUCCESS');
        window.sessionStorage.setItem('orderId', response.razorpay_order_id);
        window.sessionStorage.setItem('paymentId', response.razorpay_payment_id);
        window.sessionStorage.setItem('signature', response.razorpay_signature);
    }
    var rzp1 = new Razorpay(options);
    rzp1.on('payment.failed', function (response) {
        window.sessionStorage.setItem('razorpayStatus', 'FAILED');
        window.sessionStorage.setItem('errorCode', response.error.code);
        window.sessionStorage.setItem('errorDescription', response.error.description);
    });
    rzp1.open();
}