import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/device/device_utility.dart';
import 'package:are_mart/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon,
    this.showBackground = true,
    this.showBorder = false,
    required this.onTapSearch,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback onTapSearch;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: InkWell(
        onTap: onTapSearch,
        child: Container(
          width: TDeviceUtils.getScreenWidth(context),
          padding: EdgeInsets.all(TSizes.md.w),
          decoration: BoxDecoration(
            color:
                showBackground
                    ? dark
                        ? TColors.dark
                        : TColors.light
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: showBorder ? Border.all(color: TColors.grey) : null,
          ), // BoxDecoration
          child: Row(
            children: [
              Icon(Iconsax.search_normal, color: TColors.darkGrey),
              const SizedBox(width: TSizes.spaceBtwItems),
              Text(
                'Search in Store',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ), // ROW
        ),
      ), // Container
    );
  }
}
