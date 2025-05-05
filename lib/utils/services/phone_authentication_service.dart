import 'dart:async';

import 'package:are_mart/utils/logging/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Step 1: Send verification code
  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    Completer<bool> completer = Completer<bool>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android
        await _auth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete(true);
      },
      verificationFailed: (FirebaseAuthException e) {
        TLoggerHelper.customPrint("Verification Failed: ${e.message}");
        if (!completer.isCompleted) completer.complete(false);
      },
      codeSent: (String verificationId, int? resendToken) {
        // print(verificationId);
        _verificationId = verificationId;
        TLoggerHelper.customPrint("codeSent: $verificationId");

        if (!completer.isCompleted) completer.complete(true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        TLoggerHelper.customPrint(" code auto Timeout: $verificationId");
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete(false);
      },
      timeout: const Duration(seconds: 20),
    );

    return completer.future;
  }

  // Step 2: Verify the SMS code
  Future<UserCredential?> verifySmsCode(String smsCode) async {
    // Completer<bool> completer = Completer<bool>();
    TLoggerHelper.customPrint(smsCode);
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      print(credential);
      try {
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        return userCredential;
      } catch (e) {
        print("Error verifying SMS code: $e");
        return null;
      }
    }
    return null;
  }
}
