class Validators {
  static String? checkEmailValidity(String value) {
    const emailRegex = r'^[^@]+@[^@]+\.[^@]+$';
    bool isMatch = RegExp(emailRegex).hasMatch(value);
    if (!isMatch) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? checkPhoneValidity(String value) {
    if (value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length > 15) {
      return 'Phone number must be at most 15 digits';
    }
    if (value.length < 8) {
      return 'Phone number must be at least 8 digits';
    }

    return null;
  }

  static String? isNotEmpty(String value, {String fieldName = 'Field'}) {
    if (value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }
}
