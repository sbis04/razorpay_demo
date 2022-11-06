import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_demo/models/order.dart';
import 'package:razorpay_demo/res/palette.dart';
import 'package:razorpay_demo/secrets.dart';
import 'package:razorpay_demo/utils/validator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'models/user_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  Order? _orderDetails;

  late final Razorpay _razorpay;
  late final FirebaseFunctions _functions;

  // For TextFields
  late final TextEditingController _amountController;

  @override
  void initState() {
    _functions = FirebaseFunctions.instance;
    _amountController = TextEditingController();
    initRazorpay();
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // When payment succeeds
    log('Payment successful');
    log(
      'RESPONSE: ${response.orderId}, ${response.paymentId}, ${response.signature}',
    );
    bool isValid = await _verifySignature(
        orderId: _orderDetails?.id ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '');
    log("IS VALID: ${isValid ? 'true' : 'false'}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // When payment fails
    log('Payment error');
    log('RESPONSE (${response.code}): ${response.message}');
    setState(() => _orderDetails = null);
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

  checkoutOrder({
    required int amount, // Enter the amount in the smallest currency
    required String currency, // Eg: INR
    required String receipt, // Eg: receipt#001
    required String businessName, // Eg: Acme Corp.
    required UserDetails user,
    String description = '',
    int timeout = 60, // in seconds
  }) async {
    setState(() => _orderDetails = null);
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
      final orderDetails = Order.fromMap(responseData);
      log('ORDER ID: ${orderDetails.id}');
      setState(() => _orderDetails = orderDetails);
    } on FirebaseFunctionsException catch (error) {
      log('ERROR: ${error.code} (${error.details}): ${error.message}');
    }

    if (_orderDetails != null) {
      var options = {
        'key': RazorpaySecret.keyId,
        'amount': amount,
        'name': businessName,
        'order_id': _orderDetails!.id,
        'description': description,
        'timeout': timeout,
        'prefill': {
          'name': user.name,
          'email': user.email,
          'contact': user.contact,
        }
      };
      _razorpay.open(options);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.white,
            ),
            title: Row(
              children: [
                Image.asset(
                  'assets/razorpay_logo.png',
                  height: 36,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Demo',
                  style: TextStyle(
                    color: Palette.blueDark,
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 8),
                  InputField(
                    controller: _amountController,
                    hintText: 'Enter amount',
                    inputType: TextInputType.number,
                    inputAction: TextInputAction.next,
                    leading: const Text(
                      '₹',
                      style: TextStyle(
                        color: Palette.blueMedium,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Allow only two decimals digits
                    textInputFormatter: FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                    validator: Validator.amount,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.blueMedium,
                      disabledBackgroundColor:
                          Palette.blueMedium.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('All fields are valid!')),
                        );
                      }

                      // checkoutOrder(
                      //   amount: 50000,
                      //   currency: 'INR',
                      //   businessName: 'MyCompany',
                      //   receipt: 'receipt#001',
                      //   description: 'First order',
                      //   user: UserDetails(
                      //     name: 'Souvik Biswas',
                      //     email: 'souvik@flutterflow.io',
                      //     contact: '+919999998888',
                      //   ),
                      // );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ]
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: item,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.textInputFormatter,
    required this.inputType,
    required this.inputAction,
    this.leading,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputFormatter textInputFormatter;
  final Widget? leading;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Palette.blueDark,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
      ),
      decoration: InputDecoration(
        icon: leading,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Palette.blueMedium.withOpacity(0.4),
          fontWeight: FontWeight.normal,
          fontSize: 18,
          letterSpacing: 0.6,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Palette.blueMedium,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Palette.blueMedium,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      ),
      cursorColor: Palette.blueMedium,
      keyboardType: inputType,
      textInputAction: inputAction,
      inputFormatters: [textInputFormatter],
      validator: validator,
    );
  }
}
