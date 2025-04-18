import 'dart:io';
import 'services/email_service.dart';

void main() async {
  print('Testing DashaMail API integration...');
  
  // Real email address for testing
  final testEmail = 'nep3600@gmail.com';
  final testCode = '1234';
  
  try {
    print('Sending verification code to $testEmail...');
    await EmailService.sendVerificationCode(testEmail, testCode);
    print('Verification code sent successfully!');
  } catch (e) {
    print('Error sending verification code: $e');
    exit(1);
  }
  
  print('Test completed successfully!');
}
