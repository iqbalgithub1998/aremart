import 'package:are_mart/features/unauthorized/controllers/login_controller.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/device/device_utility.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_mobile_field/countries.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Scaffold(
      backgroundColor: TColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  SizedBox(height: TSizes.defaultSpace.h),
                  // First Row
                  SingleChildScrollView(
                    controller: controller.slideController[0].controller,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ProductContainer(product: TImages.product_0),
                        ProductContainer(product: TImages.product_1),
                        ProductContainer(product: TImages.product_2),
                        ProductContainer(product: TImages.product_3),
                        ProductContainer(product: TImages.product_4),
                        ProductContainer(product: TImages.product_5),
                      ],
                    ),
                  ),

                  // Second Row
                  SingleChildScrollView(
                    controller: controller.slideController[1].controller,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ProductContainer(product: TImages.product_6),
                        ProductContainer(product: TImages.product_7),
                        ProductContainer(product: TImages.product_8),
                        ProductContainer(product: TImages.product_9),
                        ProductContainer(product: TImages.product_10),
                        ProductContainer(product: TImages.fresh),
                      ],
                    ),
                  ),

                  // Third Row
                  SingleChildScrollView(
                    controller: controller.slideController[2].controller,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ProductContainer(product: TImages.product_12),
                        ProductContainer(product: TImages.product_13),
                        ProductContainer(product: TImages.product_14),
                        ProductContainer(product: TImages.product_15),
                        ProductContainer(product: TImages.product_16),
                        ProductContainer(product: TImages.product_11),
                      ],
                    ),
                  ),

                  // Login Section
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: LoginForm(controller: controller),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 5.w),
                decoration: BoxDecoration(color: Colors.grey.withAlpha(50)),
                child: Text.rich(
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "By Continuing, you agree to our ",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextSpan(
                        text: "Terms of Service",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: TColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: " & ",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextSpan(
                        text: "Privacy Policy",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: TColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Text(
//                   "By Continuing, you agree to our Terms of Service & Privacy Policy",
//                   style: Theme.of(context).textTheme.labelSmall,
//                   textAlign: TextAlign.center,
//                 ),
class LoginForm extends StatelessWidget {
  const LoginForm({super.key, required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    TLoggerHelper.customPrint(
      "${TDeviceUtils.getScreenWidth(context)} ${TDeviceUtils.getScreenHeight()}",
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.95),
            blurRadius: 20,
            offset: Offset(0, -20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80.w,
              height: 80.h,
              child: Card(
                elevation: 5,
                color: TColors.white,

                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10).r),
                  child: Image.asset(TImages.logo, fit: BoxFit.fill),
                ),
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Text(
              "Login or Signup",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 5),
            Text(
              "Enter your mobile number to proceed",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(color: TColors.darkGrey),
            ),
            SizedBox(height: TSizes.spaceBtwItems),

            Obx(
              () => IntlMobileField(
                focusNode: controller.mobileInputFocusNode,
                readOnly:
                    controller.initialClickOnNumberInput.value ? false : true,
                favoriteIcon: Icon(Icons.star, color: Colors.amber),
                controller: controller.mobileTextController,

                favoriteIconIsLeft: false,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
                initialCountryCode: 'IN',
                countries: [
                  Country(
                    name: "India",
                    nameTranslations: {
                      "hu": "India",
                      "sk": "India",
                      "se": "India",
                      "pl": "Indie",
                      "no": "India",
                      "ja": "インド",
                      "it": "India",
                      "zh": "印度",
                      "nl": "India",
                      "de": "Indien",
                      "fr": "Inde",
                      "es": "India",
                      "en": "India",
                      "pt_br": "Índia",
                      "sr_cyrl": "Индија",
                      "sr_latn": "Indija",
                      "zh_tw": "印度",
                      "tr": "Hindistan",
                      "ro": "India",
                      "ar": "الهند",
                      "fa": "هند",
                      "yue": "印度",
                      "bn": "ভারত",
                      "in": "भारत",
                      "ur": "بھارت",
                    },
                    flag: "🇮🇳",
                    code: "IN",
                    dialCode: "91",
                    minLength: 10,
                    maxLength: 10,
                  ),
                ],
                disableLengthCounter: true,
                languageCode: "en",
                onTap: () => controller.onInputNumberTap(context),
                onChanged: (mobile) {
                  // log(mobile.completeNumber);
                },
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? () {} : controller.sendOtp,
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
                            "Continue",
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: TColors.white),
                          ),
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class ProductContainer extends StatelessWidget {
  const ProductContainer({super.key, required this.product});

  final String product;

  @override
  Widget build(BuildContext context) {
    final height = TDeviceUtils.getScreenHeight() > 640 ? 120.h : 100.h;
    final width = TDeviceUtils.getScreenWidth(context) > 360 ? 120.w : 100.w;
    final imgheight = TDeviceUtils.getScreenHeight() > 640 ? 100.h : 90.h;
    final imgwidth = TDeviceUtils.getScreenWidth(context) > 360 ? 100.w : 90.w;
    return Container(
      padding: EdgeInsets.all(2),
      height: height,
      width: width,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: TColors.accent.withAlpha(40),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        product,
        height: imgheight,
        width: imgwidth,
        // fit: BoxFit.fill,
      ),
    );
  }
}
