import 'dart:async';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_demo/models/order_details.dart';
import 'package:razorpay_demo/models/processing_order.dart';
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
  final currencies = {
    'USD': '\$',
    'SGD': 'S\$',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'EUR': '€',
    'GBP': '£',
    'HKD': 'HK\$',
    'INR': '₹',
    'MYR': 'RM',
  };
  int _choiceChipValue = 7; // INR initially
  // Order? _orderDetails;
  // late PaymentStatus _paymentStatus;

  // late final FirebaseFunctions _functions;

  // For TextFields
  late final TextEditingController _amountController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _receiptController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _userNameController;
  late final TextEditingController _userEmailController;
  late final TextEditingController _userContactController;

  bool _isErrorBarVisible = false;
  // bool _isBottomSheetVisible = false;
  late PaymentStatus _paymentStatus;

  Timer? _timer;

  void _showErrorBar({required int timeoutSeconds}) {
    setState(() => _isErrorBarVisible = true);
    var start = timeoutSeconds;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          timer.cancel();
          setState(() => _isErrorBarVisible = false);
        } else {
          start--;
        }
      },
    );
  }

  @override
  void initState() {
    // _functions = FirebaseFunctions.instance;
    _paymentStatus = PaymentStatus.idle;
    _amountController = TextEditingController();
    _businessNameController = TextEditingController();
    _receiptController = TextEditingController(text: 'receipt#001');
    _descriptionController = TextEditingController();
    _userNameController = TextEditingController();
    _userEmailController = TextEditingController();
    _userContactController = TextEditingController();
    // initRazorpay();
    super.initState();
  }

  @override
  void dispose() {
    // _razorpay.clear();
    _timer?.cancel();
    super.dispose();
  }

  // initRazorpay() {
  //   _razorpay = Razorpay();
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  //   _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  // }

  // Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   // When payment succeeds
  //   log('Payment successful');
  //   log(
  //     'RESPONSE: ${response.orderId}, ${response.paymentId}, ${response.signature}',
  //   );
  //   bool isValid = await _verifySignature(
  //       orderId: _orderDetails?.id ?? '',
  //       paymentId: response.paymentId ?? '',
  //       signature: response.signature ?? '');
  //   log("IS VALID: ${isValid ? 'true' : 'false'}");
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   // When payment fails
  //   log('Payment error');
  //   log('RESPONSE (${response.code}): ${response.message}');
  //   setState(() => _orderDetails = null);
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   // When an external wallet was selected
  //   log('Payment external wallet');
  //   log('RESPONSE: ${response.walletName}');
  // }

  // Future<bool> _verifySignature({
  //   required String orderId,
  //   required String paymentId,
  //   required String signature,
  // }) async {
  //   try {
  //     final result = await _functions.httpsCallable('verifySignature').call(
  //       <String, dynamic>{
  //         'orderId': orderId,
  //         'paymentId': paymentId,
  //         'signature': signature,
  //       },
  //     );
  //     return result.data;
  //   } on FirebaseFunctionsException catch (error) {
  //     log('ERROR: ${error.code} (${error.details}): ${error.message}');
  //   }
  //   return false;
  // }

  // checkoutOrder({
  //   required int amount, // Enter the amount in the smallest currency
  //   required String currency, // Eg: INR
  //   required String receipt, // Eg: receipt#001
  //   required String businessName, // Eg: Acme Corp.
  //   required UserDetails user,
  //   String description = '',
  //   int timeout = 60, // in seconds
  // }) async {
  //   setState(() => _orderDetails = null);
  //   try {
  //     final result = await _functions.httpsCallable('createOrder').call(
  //       <String, dynamic>{
  //         'amount': amount,
  //         'currency': currency,
  //         'receipt': receipt,
  //         'description': description,
  //       },
  //     );
  //     final responseData = result.data as Map<String, dynamic>;
  //     final orderDetails = Order.fromMap(responseData);
  //     log('ORDER ID: ${orderDetails.id}');
  //     setState(() => _orderDetails = orderDetails);
  //   } on FirebaseFunctionsException catch (error) {
  //     log('ERROR: ${error.code} (${error.details}): ${error.message}');
  //   }

  //   if (_orderDetails != null) {
  //     var options = {
  //       'key': RazorpaySecret.keyId,
  //       'amount': amount,
  //       'name': businessName,
  //       'order_id': _orderDetails!.id,
  //       'description': description,
  //       'timeout': timeout,
  //       'prefill': {
  //         'name': user.name,
  //         'email': user.email,
  //         'contact': user.contact,
  //       }
  //     };
  //     _razorpay.open(options);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final Color statusBarColor;
    final Color navBarColor;
    switch (_paymentStatus) {
      case PaymentStatus.processing:
        statusBarColor = Colors.transparent;
        navBarColor = Palette.blueMedium;
        break;
      case PaymentStatus.success:
        statusBarColor = Colors.transparent;
        navBarColor = Colors.green;
        break;
      case PaymentStatus.failed:
        statusBarColor = Colors.transparent;
        navBarColor = Colors.red;
        break;
      default:
        statusBarColor = Colors.white;
        navBarColor = Colors.white;

        break;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navBarColor,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: statusBarColor,
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
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 8),
                      InputField(
                        controller: _amountController,
                        label: 'Amount',
                        hintText: 'Enter amount',
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.next,
                        leading: Text(
                          currencies.values.elementAt(_choiceChipValue),
                          style: const TextStyle(
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
                      ExcludeFocus(
                        child: Wrap(
                          children: List.generate(
                            currencies.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: ChoiceChip(
                                label: Text(currencies.keys.toList()[index]),
                                selected: _choiceChipValue == index,
                                backgroundColor:
                                    Palette.blueMedium.withOpacity(0.4),
                                selectedColor: Palette.blueMedium,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 8,
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.6,
                                ),
                                onSelected: (value) {
                                  if (value) {
                                    setState(() => _choiceChipValue = index);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      InputField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        hintText: 'Enter your business name',
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        // Allow only two decimals digits
                        validator: Validator.businessName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      InputField(
                        controller: _receiptController,
                        label: 'Receipt',
                        hintText: 'Enter your receipt',
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        // Allow only two decimals digits
                        validator: Validator.receipt,
                      ),
                      InputField(
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Enter a description of the order',
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        // Allow only two decimals digits
                        validator: Validator.description,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Palette.blueDark,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'User details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              InputField(
                                controller: _userNameController,
                                label: 'Name',
                                hintText: 'Enter your name',
                                inputType: TextInputType.name,
                                inputAction: TextInputAction.next,
                                validator: Validator.name,
                                primaryColor: Colors.white,
                                errorColor: Colors.redAccent,
                                textColor: Colors.white,
                                textCapitalization: TextCapitalization.words,
                              ),
                              InputField(
                                controller: _userEmailController,
                                label: 'Email',
                                hintText: 'Enter your email',
                                inputType: TextInputType.emailAddress,
                                inputAction: TextInputAction.next,
                                validator: Validator.email,
                                primaryColor: Colors.white,
                                errorColor: Colors.redAccent,
                                textColor: Colors.white,
                              ),
                              InputField(
                                controller: _userContactController,
                                label: 'Contact',
                                hintText: 'Enter your phone number',
                                inputType: TextInputType.phone,
                                inputAction: TextInputAction.done,
                                validator: Validator.contact,
                                primaryColor: Colors.white,
                                errorColor: Colors.redAccent,
                                textColor: Colors.white,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ]
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: item,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() =>
                                _paymentStatus = PaymentStatus.processing);
                            await showModalBottomSheet(
                              context: context,
                              barrierColor: Palette.blueDark.withOpacity(0.5),
                              isDismissible: false,
                              builder: (context) {
                                final order = OrderDetails(
                                  amount:
                                      (double.parse(_amountController.text) *
                                              100)
                                          .toInt(),
                                  currency:
                                      currencies[_choiceChipValue] ?? 'INR',
                                  businessName: _businessNameController.text,
                                  receipt: _receiptController.text,
                                  description: _descriptionController.text,
                                  user: UserDetails(
                                    name: _userNameController.text,
                                    email: _userEmailController.text,
                                    contact: _userContactController.text,
                                  ),
                                );

                                return ProgressBottomSheet(
                                  orderDetails: order,
                                  onPaymentStateChange: (status) =>
                                      setState(() => _paymentStatus = status),
                                );
                              },
                            );
                            setState(() => _paymentStatus = PaymentStatus.idle);

                            // await Future.delayed(const Duration(seconds: 2),
                            //     () {
                            //   setState(() {
                            //     _paymentStatus = PaymentStatus.success;
                            //   });
                            // });
                            // setState(() => _isBottomSheetVisible = false);
                          } else {
                            // If the form is not valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            _showErrorBar(timeoutSeconds: 4);
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
              AnimatedOpacity(
                opacity: _isErrorBarVisible ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'All fields are not valid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    _functions = FirebaseFunctions.instance;
    _paymentStatus = PaymentStatus.processing;
    _orderDetails = widget.orderDetails;
    startCheckout();
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  startCheckout() {
    _razorpay = Razorpay();
    _paymentStatus = PaymentStatus.idle;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    checkoutOrder(
      amount: _orderDetails.amount,
      currency: _orderDetails.currency,
      businessName: _orderDetails.businessName,
      receipt: _orderDetails.receipt,
      description: _orderDetails.description,
      user: _orderDetails.user,
    );
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
    log("IS VALID: ${isValid ? 'true' : 'false'}");

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
    log('RESPONSE (${response.code}): ${response.message}');
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

  checkoutOrder({
    required int amount, // Enter the amount in the smallest currency
    required String currency, // Eg: INR
    required String receipt, // Eg: receipt#001
    required String businessName, // Eg: Acme Corp.
    required UserDetails user,
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
      var options = {
        'key': RazorpaySecret.keyId,
        'amount': amount,
        'name': businessName,
        'order_id': _processingOrderDetails!.id,
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

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputFormatter,
    required this.inputType,
    required this.inputAction,
    required this.label,
    this.leading,
    this.validator,
    this.primaryColor = Palette.blueMedium,
    this.textColor = Palette.blueDark,
    this.errorColor = Colors.red,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputFormatter? textInputFormatter;
  final Widget? leading;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final String? Function(String?)? validator;
  final String label;
  final Color primaryColor;
  final Color textColor;
  final Color errorColor;
  final TextCapitalization textCapitalization;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
      ),
      decoration: InputDecoration(
        icon: leading,
        hintText: hintText,
        label: Text(
          label,
          style: TextStyle(
            color: primaryColor.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
        hintStyle: TextStyle(
          color: primaryColor.withOpacity(0.4),
          fontWeight: FontWeight.normal,
          fontSize: 18,
          letterSpacing: 0.6,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorStyle: TextStyle(color: errorColor),
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      ),
      cursorColor: primaryColor,
      keyboardType: inputType,
      textInputAction: inputAction,
      inputFormatters:
          textInputFormatter != null ? [textInputFormatter!] : null,
      validator: validator,
    );
  }
}
