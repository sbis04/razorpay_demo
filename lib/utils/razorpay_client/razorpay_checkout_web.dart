// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:razorpay_demo/utils/razorpay_client/razorpay_checkout.dart';

class RazorpayCheckout extends RazorpayCheckoutBase {
  @override
  Future<Map<String, String>> checkout(Map<String, dynamic> options) async {
    Completer<Map<String, String>> completer = Completer<Map<String, String>>();
    // Calls JS function
    js.context.callMethod('checkout', [jsonEncode(options)]);
    Timer? periodicTimer;
    periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (html.window.sessionStorage.containsKey('razorpayStatus')) {
        Map<String, String> data = Map.fromEntries(
          html.window.sessionStorage.entries,
        );
        html.window.sessionStorage.clear();
        completer.complete(data);
        periodicTimer?.cancel();
        periodicTimer = null;
      }
    });
    return completer.future;
  }
}
