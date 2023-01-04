import 'package:razorpay_demo/models/razorpay_options.dart';

class OrderDetails {
  final int amount;
  final String currency;
  final String businessName;
  final String receipt;
  final String description;
  final Prefill prefill;

  OrderDetails({
    required this.amount,
    required this.currency,
    required this.businessName,
    required this.receipt,
    required this.description,
    required this.prefill,
  });
}
