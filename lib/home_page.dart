import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_demo/models/order_details.dart';
import 'package:razorpay_demo/models/razorpay_options.dart';
import 'package:razorpay_demo/res/palette.dart';
import 'package:razorpay_demo/utils/validator.dart';
import 'package:razorpay_demo/widgets/input_field.dart';
import 'package:razorpay_demo/widgets/progress_bottom_sheet.dart';

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

  // For TextFields
  late final TextEditingController _amountController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _receiptController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _userNameController;
  late final TextEditingController _userEmailController;
  late final TextEditingController _userContactController;

  bool _isErrorBarVisible = false;
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

  Future<void> _onTapCheckout() async {
    setState(() => _paymentStatus = PaymentStatus.processing);
    await showModalBottomSheet(
      context: context,
      barrierColor: Palette.blueDark.withOpacity(0.5),
      isDismissible: false,
      builder: (context) {
        final order = OrderDetails(
          amount: (double.parse(_amountController.text) * 100).toInt(),
          currency: currencies.keys.toList()[_choiceChipValue],
          businessName: _businessNameController.text,
          receipt: _receiptController.text,
          description: _descriptionController.text,
          prefill: Prefill(
            userName: _userNameController.text,
            userEmail: _userEmailController.text,
            userContact: _userContactController.text,
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
  }

  @override
  void initState() {
    _paymentStatus = PaymentStatus.idle;
    _amountController = TextEditingController();
    _businessNameController = TextEditingController();
    _receiptController = TextEditingController(text: 'receipt#001');
    _descriptionController = TextEditingController();
    _userNameController = TextEditingController();
    _userEmailController = TextEditingController();
    _userContactController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
      value: SystemUiOverlayStyle(systemNavigationBarColor: navBarColor),
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
                          runSpacing: 8,
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
                        validator: Validator.businessName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      InputField(
                        controller: _receiptController,
                        label: 'Receipt',
                        hintText: 'Enter your receipt',
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        validator: Validator.receipt,
                      ),
                      InputField(
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Enter a description of the order',
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _onTapCheckout();
                          } else {
                            _showErrorBar(timeoutSeconds: 4);
                          }
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
