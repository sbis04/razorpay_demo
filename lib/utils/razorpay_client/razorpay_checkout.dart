abstract class RazorpayCheckoutBase {
  void checkout(
    Map<String, dynamic> options,
    Function(String) webCheckoutResponse,
  );
}
