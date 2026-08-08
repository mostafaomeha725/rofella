import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ResponsiveFontSize on num {
  /// Custom responsive font scaler that clamps the scaling factor.
  /// This prevents fonts from becoming massively distorted on desktop browsers,
  /// or unreadably small on tiny devices, by restricting the scale between 0.8x and 1.5x.
  double get rsp => sp.clamp(this * 0.8, this * 1.5).toDouble();
}

TextStyle get font8w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 8.rsp);

TextStyle get font10w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 10.rsp);

TextStyle get font10w400 =>
    TextStyle(fontWeight: FontWeight.w400, fontSize: 10.rsp);

TextStyle get font10w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 10.rsp);

TextStyle get font12w400 =>
    TextStyle(fontWeight: FontWeight.w400, fontSize: 12.rsp);

TextStyle get font12w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 12.rsp);

TextStyle get font12w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 12.rsp);

TextStyle get font13w600 =>
    TextStyle(fontWeight: FontWeight.w600, fontSize: 13.rsp);

TextStyle get font14w400 =>
    TextStyle(fontWeight: FontWeight.w400, fontSize: 14.rsp);

TextStyle get font14w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 14.rsp);

TextStyle get font14w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 14.rsp);

TextStyle get font16w300 =>
    TextStyle(fontWeight: FontWeight.w300, fontSize: 16.rsp);

TextStyle get font16w400 =>
    TextStyle(fontWeight: FontWeight.w400, fontSize: 16.rsp);

TextStyle get font16w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 16.rsp);

TextStyle get font16w600 =>
    TextStyle(fontWeight: FontWeight.w600, fontSize: 16.rsp);

TextStyle get font16w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 16.rsp);

TextStyle get font18w300 =>
    TextStyle(fontWeight: FontWeight.w300, fontSize: 18.rsp);

TextStyle get font18w400 =>
    TextStyle(fontWeight: FontWeight.w400, fontSize: 18.rsp);

TextStyle get font18w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 18.rsp);

TextStyle get font18w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 18.rsp);

TextStyle get font20w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 20.rsp);

TextStyle get font20w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 20.rsp);

TextStyle get font22w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 22.rsp);

TextStyle get font22w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 22.rsp);

TextStyle get font24w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 24.rsp);

TextStyle get font24w800 =>
    TextStyle(fontWeight: FontWeight.w800, fontSize: 24.rsp);

TextStyle get font26w400 =>
    TextStyle(fontWeight: FontWeight.w400, fontSize: 26.rsp);

TextStyle get font26w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 26.rsp);

TextStyle get font28w500 =>
    TextStyle(fontWeight: FontWeight.w500, fontSize: 28.rsp);

TextStyle get font30w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 30.rsp);

TextStyle get font32w700 =>
    TextStyle(fontWeight: FontWeight.w700, fontSize: 32.rsp);

TextStyle get font36w800 =>
    TextStyle(fontWeight: FontWeight.w800, fontSize: 36.rsp);
