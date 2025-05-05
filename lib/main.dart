import 'package:are_mart/app.dart';
import 'package:are_mart/firebase_options.dart';
import 'package:are_mart/utils/data/auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // WidgetsFlutterBinding.ensureInitialized();
  //* GetX local Storage
  await GetStorage.init();

  //* Initialize Firebase

  //*  preserve Splash until item Load...
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Get.put(AuthRepository());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}
