import 'package:are_mart/features/common/widgets/curved_edges_widget.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TPrimaryHeader extends StatelessWidget {
  const TPrimaryHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgesWidget(
      child: Container(
        color: TColors.primary,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: CircularContainer(
                  backgroundColor: TColors.textWhite.withAlpha(50),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: CircularContainer(
                  backgroundColor: TColors.textWhite.withAlpha(40),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
