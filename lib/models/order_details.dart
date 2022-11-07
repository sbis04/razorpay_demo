import 'package:razorpay_demo/models/user_details.dart';

class OrderDetails {
  final int amount;
  final String currency;
  final String businessName;
  final String receipt;
  final String description;
  final UserDetails user;

  OrderDetails({
    required this.amount,
    required this.currency,
    required this.businessName,
    required this.receipt,
    required this.description,
    required this.user,
  });
}
