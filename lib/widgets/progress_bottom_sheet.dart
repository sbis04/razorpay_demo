import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_demo/models/order_details.dart';
import 'package:razorpay_demo/models/processing_order.dart';
import 'package:razorpay_demo/models/razorpay_options.dart';
import 'package:razorpay_demo/models/razorpay_response.dart';
import 'package:razorpay_demo/res/palette.dart';
import 'package:razorpay_demo/secrets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_demo/utils/razorpay_client/razorpay_checkout_stub.dart'
    if (dart.library.html) 'package:razorpay_demo/utils/razorpay_client/razorpay_checkout_web.dart';

enum PaymentStatus {
  idle,
  processing,
  success,
  failed,
}

class ProgressBottomSheet extends StatefulWidget {
  const ProgressBottomSheet({
    Key? key,
    required this.orderDetails,
    required this.onPaymentStateChange,
  }) : super(key: key);

  final OrderDetails orderDetails;
  final Function(PaymentStatus) onPaymentStateChange;

  @override
  State<ProgressBottomSheet> createState() => _ProgressBottomSheetState();
}

class _ProgressBottomSheetState extends State<ProgressBottomSheet> {
  late final Razorpay _razorpay;
  late final FirebaseFunctions _functions;
  late final OrderDetails _orderDetails;
  ProcessingOrder? _processingOrderDetails;
  late PaymentStatus _paymentStatus;
  late final RazorpayCheckout _razorpayCheckout;

  @override
  void initState() {
    _orderDetails = widget.orderDetails;
    _functions = FirebaseFunctions.instance;
    _razorpayCheckout = RazorpayCheckout();
    _initializeRazorpay();
    _checkoutOrder(
      amount: _orderDetails.amount,
      currency: _orderDetails.currency,
      businessName: _orderDetails.businessName,
      receipt: _orderDetails.receipt,
      description: _orderDetails.description,
      prefill: _orderDetails.prefill,
    );
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _webCheckoutResponse(String data) {
    final checkoutResponse = RazorpayResponse.fromJson(data);
    if (checkoutResponse.isSuccessful) {
      _handlePaymentSuccess(PaymentSuccessResponse(
        checkoutResponse.paymentId,
        checkoutResponse.orderId,
        checkoutResponse.signature,
      ));
    } else {
      _handlePaymentError(PaymentFailureResponse(
        Razorpay.UNKNOWN_ERROR,
        Razorpay.EVENT_PAYMENT_ERROR,
        {
          'errorCode': checkoutResponse.errorCode,
          'errorDescription': checkoutResponse.errorDescription,
        },
      ));
    }
  }

  _initializeRazorpay() {
    _paymentStatus = PaymentStatus.idle;
    _razorpay = Razorpay();
    if (!kIsWeb) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // When payment succeeds
    log('Payment successful');
    log(
      'RESPONSE: ${response.orderId}, ${response.paymentId}, ${response.signature}',
    );
    bool isValid = await _verifySignature(
        orderId: _processingOrderDetails?.id ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '');
    if (isValid) {
      setState(() => _paymentStatus = PaymentStatus.success);
    } else {
      setState(() => _paymentStatus = PaymentStatus.failed);
    }
    widget.onPaymentStateChange(_paymentStatus);
    Future.delayed(
      const Duration(seconds: 2),
      () => Navigator.of(context).pop(),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // When payment fails
    log('Payment error');
    log('RESPONSE (${response.code}): ${response.message}, ${response.error}');
    setState(() {
      _processingOrderDetails = null;
      _paymentStatus = PaymentStatus.failed;
    });
    widget.onPaymentStateChange(_paymentStatus);
    Future.delayed(
      const Duration(seconds: 2),
      () => Navigator.of(context).pop(),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // When an external wallet was selected
    log('Payment external wallet');
    log('RESPONSE: ${response.walletName}');
  }

  Future<bool> _verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final result = await _functions.httpsCallable('verifySignature').call(
        <String, dynamic>{
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        },
      );
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      log('ERROR: ${error.code} (${error.details}): ${error.message}');
    }
    return false;
  }

  Future<void> _checkoutOrder({
    required int amount, // Enter the amount in the smallest currency
    required String currency, // Eg: INR
    required String receipt, // Eg: receipt#001
    required String businessName, // Eg: Acme Corp.
    required Prefill prefill,
    String description = '',
    int timeout = 60, // in seconds
  }) async {
    setState(() => _processingOrderDetails = null);
    try {
      final result = await _functions.httpsCallable('createOrder').call(
        <String, dynamic>{
          'amount': amount,
          'currency': currency,
          'receipt': receipt,
          'description': description,
        },
      );
      final responseData = result.data as Map<String, dynamic>;
      final orderDetails = ProcessingOrder.fromMap(responseData);
      log('ORDER ID: ${orderDetails.id}');
      setState(() => _processingOrderDetails = orderDetails);
    } on FirebaseFunctionsException catch (error) {
      log('ERROR: ${error.code} (${error.details}): ${error.message}');
    }

    if (_processingOrderDetails != null) {
      final options = RazorpayOptions(
        key: RazorpaySecret.keyId,
        amount: amount,
        businessName: businessName,
        orderId: _processingOrderDetails!.id!,
        description: description,
        timeout: timeout,
        prefill: prefill,
        retry: Retry(enabled: false),
      ).toMap();
      if (kIsWeb) {
        _razorpayCheckout.checkout(options, _webCheckoutResponse);
      } else {
        _razorpay.open(options);
      }
    }
  }

  Widget circularProgressIndicator() => const SizedBox(
        height: 26,
        width: 26,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white,
          ),
          strokeWidth: 3,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final String text;
    final Widget trailingWidget;
    switch (_paymentStatus) {
      case PaymentStatus.processing:
        backgroundColor = Palette.blueMedium;
        text = 'Processing...';
        trailingWidget = circularProgressIndicator();
        break;
      case PaymentStatus.success:
        backgroundColor = Colors.green;
        text = 'Payment successful';
        trailingWidget = CircleAvatar(
          backgroundColor: Colors.green.shade900,
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 26,
          ),
        );

        break;
      case PaymentStatus.failed:
        backgroundColor = Colors.red;
        text = 'Payment Failed';
        trailingWidget = CircleAvatar(
          backgroundColor: Colors.red.shade800,
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 26,
          ),
        );
        break;
      default:
        backgroundColor = Palette.blueMedium;
        text = 'Processing...';
        trailingWidget = circularProgressIndicator();
        break;
    }
    return Container(
      width: double.maxFinite,
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_paymentStatus == PaymentStatus.processing)
            LinearProgressIndicator(
              backgroundColor: backgroundColor,
              color: Palette.blueDark.withOpacity(0.5),
              minHeight: 5,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                trailingWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
