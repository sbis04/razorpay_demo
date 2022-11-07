class Validator {
  static String? amount(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter an amount';
    }

    final value = double.tryParse(input) ?? 0.0;
    if (value <= 0.0) {
      return 'Enter an amount greater than 0';
    }

    return null;
  }

  static String? businessName(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a business name';
    }

    return null;
  }

  static String? receipt(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a receipt number';
    }

    return null;
  }

  static String? description(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a receipt number';
    }

    return null;
  }

  static String? name(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter your name';
    }

    return null;
  }

  static String? email(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter your email';
    }

    return null;
  }

  static String? contact(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter your phone number';
    }

    return null;
  }
}
