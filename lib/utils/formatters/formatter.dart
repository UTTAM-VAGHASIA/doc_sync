import 'package:intl/intl.dart';

class AppFormatter {
  static String formatDateForDisplay(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('yyyy/MM/dd').format(date);
    final onlyTime = DateFormat('hh:mm').format(date);
    return '$onlyDate at $onlyTime';
  }

  static String formatDateForApi(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('dd/MM/yyyy').format(date);
    final onlyTime = DateFormat('hh:mm').format(date);
    return '$onlyDate at $onlyTime';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    ).format(amount); // Customize the currency locale and symbol as needed
  }

  // static String formatPhoneNumber(String phoneNumber) {
  //   // Assuming a 10-digit US phone number format: (123) 456-7890
  //   if (phoneNumber.length == 10) {
  //     return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
  //   } else if (phoneNumber.length == 11) {
  //     return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
  //   }
  //   // Add more custom phone number formatting logic for different formats if needed.
  //   return phoneNumber;
  // }

  static String formatPhoneNumber(String phoneNumber) {
    // Remove non-digit characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Handle country code (e.g., +91 or 91 prefix)
    if (phoneNumber.startsWith('91') && phoneNumber.length == 12) {
      phoneNumber = phoneNumber.substring(2); // Remove '91'
    }

    // Format 10-digit mobile number
    if (phoneNumber.length == 10) {
      return '${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }

    // Format 11-digit landline number (STD code)
    if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
      // Extract STD code (assuming first 3-5 digits as STD code)
      int stdLength = (phoneNumber[1] == '1' || phoneNumber[1] == '2') ? 3 : 4;
      return '(${phoneNumber.substring(0, stdLength)}) ${phoneNumber.substring(stdLength)}';
    }

    return phoneNumber; // Return as is if it doesn't match known formats
  }

  // Not fully tested.
  // static String internationalFormatPhoneNumber(String phoneNumber) {
  //   // Remove any non-digit characters from the phone number
  //   var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
  //
  //   // Extract the country code from the digitsOnly
  //   String countryCode = '+${digitsOnly.substring(0, 2)}';
  //   digitsOnly = digitsOnly.substring(2);
  //
  //   // Add the remaining digits with proper formatting
  //   final formattedNumber = StringBuffer();
  //   formattedNumber.write('($countryCode) ');
  //
  //   int i = 0;
  //   while (i < digitsOnly.length) {
  //     int groupLength = 2;
  //     if (i == 0 && countryCode == '+1') {
  //       groupLength = 3;
  //     }
  //
  //     int end = i + groupLength;
  //     formattedNumber.write(digitsOnly.substring(i, end));
  //
  //     if (end < digitsOnly.length) {
  //       formattedNumber.write(' ');
  //     }
  //     i = end;
  //   }
  //
  //   return formattedNumber.toString();
  // }

  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure we have at least 3 digits (to cover most country codes)
    if (digitsOnly.length < 3) return phoneNumber; // Return as-is if too short

    // Detect country code dynamically (assume 1-3 digits)
    String countryCode = '+';
    int countryCodeLength = 1;

    if (digitsOnly.startsWith('1')) {
      countryCode += '1'; // US/Canada
      countryCodeLength = 1;
    } else if (digitsOnly.startsWith('91')) {
      countryCode += '91'; // India
      countryCodeLength = 2;
    } else if (digitsOnly.startsWith('44')) {
      countryCode += '44'; // UK
      countryCodeLength = 2;
    } else if (digitsOnly.startsWith('971')) {
      countryCode += '971'; // UAE
      countryCodeLength = 3;
    } else {
      // Default to first 2 digits as country code
      countryCode += digitsOnly.substring(0, 2);
      countryCodeLength = 2;
    }

    // Remove country code from the number
    digitsOnly = digitsOnly.substring(countryCodeLength);

    // Format number based on country
    String formattedNumber;
    if (countryCode == '+1') {
      // US/Canada format: +1 (XXX) XXX-XXXX
      formattedNumber =
          '($countryCode) (${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (countryCode == '+91') {
      // India format: +91 XXXXX-XXXXX
      formattedNumber =
          '($countryCode) ${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5)}';
    } else if (countryCode == '+44') {
      // UK format: +44 XXXX XXXXXX
      formattedNumber =
          '($countryCode) ${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
    } else {
      // Default grouping for unknown formats
      formattedNumber =
          '($countryCode) ${digitsOnly.replaceAllMapped(RegExp(r'(\d{2,3})'), (m) => '${m[0]} ').trim()}';
    }

    return formattedNumber;
  }
}
