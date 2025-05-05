import 'package:are_mart/features/unauthorized/controllers/login_controller.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:pinput/pinput.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key, required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    controller.countdown();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(CupertinoIcons.back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verification code",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 5),
              Text(
                "We 2 have sent the code verification to",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: TColors.buttonSecondary,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: <Widget>[
                  Text(
                    "+91******${number.substring(9)}",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      "Change phone number?",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: TColors.primary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // OTP TextField
              Pinput(
                length: 6,
                onChanged: (value) => controller.otp.value = value,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Verify Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style,
                    onPressed:
                        controller.otp.value.length == 6
                            ? controller.verifyOTP
                            : () {},
                    child:
                        controller.isLoading.value
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: TColors.white,
                              ),
                            )
                            : Text(
                              "Verify OTP",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(
                                color: TColors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Resend OTP Timer
              Obx(
                () =>
                    controller.isResendEnabled.value
                        ? Center(
                          child: TextButton(
                            onPressed: controller.startResendTimer,
                            child: Text("Resend OTP"),
                          ),
                        )
                        : Center(
                          child: Text(
                            "Resend in ${controller.secondsRemaining.value} seconds",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
