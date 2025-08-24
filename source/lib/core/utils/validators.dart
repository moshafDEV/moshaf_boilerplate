class Validators {
  static String? checkEmailValidity(String value) {
    const emailRegex = r'^[^@]+@[^@]+\.[^@]+$';
    bool isMatch = RegExp(emailRegex).hasMatch(value);
    if (!isMatch) {
      return 'Format email tidak sesuai';
    }
    return null;
  }

  static String? checkPhoneValidity(String value) {
    if (value.isEmpty) {
      return 'Nomor ponsel harus diisi';
    }
    if (value.length > 15) {
      return 'Nomor ponsel maksimal 15 digit';
    }
    if (value.length < 8) {
      return 'Nomor ponsel minimal 8 digit';
    }

    return null;
  }

  static String? isNotEmpty(String value, {String fieldName = 'Field'}) {
    if (value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }
}
