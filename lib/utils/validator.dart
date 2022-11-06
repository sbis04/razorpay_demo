class Validator {
  static String? amount(String? input) {
    if (input == null) {
      return 'Please enter an amount';
    }

    final value = double.tryParse(input) ?? 0.0;
    if (value <= 0.0) {
      return 'Enter an amount greater than 0';
    }

    return null;
  }
}
