import 'package:custom_dropdown_widget/validation_error_text.dart';

class Validator {
  static String? nullFieldValidate(String value) =>
      value.trim().isEmpty ? ValidationErrorText.thisFieldIsRequired : null;

  static String? validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());

    if (value.isEmpty) {
      return ValidationErrorText.pleaseEnterEmailText;
    } else if (!regex.hasMatch(value)) {
      return ValidationErrorText.pleaseEnterAValidEmailText;
    } else {
      return null;
    }
  }

  static String? validatePassword(String value) {
    final RegExp passwordRegExp = RegExp(
      r'(?=.*?[0-9])(?=.*?[A-Za-z]).+',
    );
    if (value.isEmpty) {
      return ValidationErrorText.thisFieldIsRequired;
    } else if (value.length < 8) {
      return ValidationErrorText.passwordMustBeEight;
    } else if (!passwordRegExp.hasMatch(value)) {
      return ValidationErrorText.passwordRequirementText;
    } else {
      return null;
    }
  }

  static String? validateEmptyPassword(String value) {
    if (value.isEmpty) {
      return ValidationErrorText.pleaseEnterPasswordText;
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(
      String password, String confirmPassword) {
    if (password != confirmPassword) {
      return ValidationErrorText.passwordDoesNotMatch;
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String value) {
//    Pattern pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    Pattern pattern = r'\+?(88)?0?1[3456789][0-9]{8}\b';
    RegExp regex = RegExp(pattern.toString());
    if (value.trim() == '') {
      return ValidationErrorText.enterValidPhoneNumber;
    } else if (value.trim().length > 11) {
      return ValidationErrorText.enterValidPhoneNumber;
    } else if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.enterValidPhoneNumber;
    } else {
      return null;
    }
  }

  static String? validateNid(String value) {
    if (value.trim().isEmpty) {
      return null;
    } else if (value.trim().length <= 9) {
      return ValidationErrorText.enterAtLeastValidNid;
    } else if (value.trim().length >= 18) {
      return ValidationErrorText.enterAtMostValidNid;
    } else {
      return null;
    }
  }

  static String? validateNullablePhoneNumber(String value) {
    Pattern pattern = r'\+?(88)?0?1[3456789][0-9]{8}\b';
    RegExp regex = RegExp(pattern.toString());
    if (value.trim() == '') {
      return null;
    } else if (value.trim().length > 11) {
      return ValidationErrorText.enterValidPhoneNumber;
    } else if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.enterValidPhoneNumber;
    } else {
      return null;
    }
  }

  static String? validatePhoneNumberForVerification(String value) {
    Pattern pattern = r'\+?(88)?0?1[3456789][0-9]{8}\b';
    RegExp regex = RegExp(pattern.toString());
    if (value.trim() == '') {
      return ValidationErrorText.phoneVerificationEnterValidPhoneNumber;
    } else if (value.trim().length > 11) {
      return ValidationErrorText.phoneVerificationEnterValidPhoneNumber;
    } else if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.phoneVerificationEnterValidPhoneNumber;
    } else {
      return null;
    }
  }

  static String? verificationCodeValidator(String value) {
    Pattern pattern = r'^(\d{6})?$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.invalidCode;
    } else {
      return null;
    }
  }

  static String? numberFieldValidateOptional(String value) {
    Pattern pattern = r'^[1-9]\d*(\.\d+)?$';
    RegExp regex = RegExp(pattern.toString());
    if (value.trim().isEmpty) {
      return null;
    }

    if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.pleaseEnterDecimalValue;
    } else {
      return null;
    }
  }

  static String? validateFirstLetterTitle(String value) {
    if (value.substring(0, 1).toUpperCase() != value.substring(0, 1)) {
      return ValidationErrorText.pleaseCheckYourInput;
    } else {
      return null;
    }
  }

  static String? validateNonMandatoryEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());

    if (value.trim().isEmpty) {
      return null;
    } else if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.pleaseEnterAValidEmailText;
    } else {
      return null;
    }
  }

  static String? firstCharacterValidate(String value) {
    Pattern pattern = r'^([A-Z])\w';
    RegExp regex = RegExp(pattern.toString());
    if (value.isNotEmpty && !regex.hasMatch(value)) {
      return ValidationErrorText.pleaseCheckYourInput;
    } else if (value.isEmpty) {
      return ValidationErrorText.thisFieldIsRequired;
    } else {
      return null;
    }
  }

  static String? decimalNumberFieldValidateOptional(String value) {
    String pattern = r'^[1-9]\d*(\.\d+)?$';
    RegExp regex = RegExp(pattern);
    if (value.trim().isEmpty) {
      return null;
    }

    if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.pleaseEnterDecimalValue;
    } else {
      return null;
    }
  }

  static String? integerNumberNullableValidator(String value) {
    String pattern = r'^[1-9][0-9]*$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return null;
    } else if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.pleaseEnterValidNumber;
    } else {
      return null;
    }
  }

  static String? integerNumberValidator(String value) {
    String pattern = r'^[1-9][0-9]*$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value.trim())) {
      return ValidationErrorText.pleaseEnterValidNumber;
    } else {
      return null;
    }
  }
}
