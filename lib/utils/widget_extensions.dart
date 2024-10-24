import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension WidgetExtension on Widget {
  Widget pSymmetric({double? horizontal, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontal ?? 16.w, vertical: vertical),
      child: this,
    );
  }

  Widget pOnly(
      {double top = 0, double right = 0, double bottom = 0, double left = 0}) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
      child: this,
    );
  }

  Widget spSymmetric({double? horizontal, double vertical = 0}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontal ?? 16.w, vertical: vertical),
      sliver: this,
    );
  }

  Widget spOnly(
      {double top = 0, double right = 0, double bottom = 0, double left = 0}) {
    return SliverPadding(
      padding:
          EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
      sliver: this,
    );
  }

  Widget shimmer({Duration? duration, Duration? delay}) {
    return animate(onComplete: (controller) => controller.repeat()).shimmer(
        delay: delay ?? const Duration(milliseconds: 500),
        duration: duration ?? const Duration(milliseconds: 1400));
  }
}
