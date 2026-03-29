import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration sheetEnter = Duration(milliseconds: 320);
  static const Duration sheetExit = Duration(milliseconds: 220);
  static const Duration pageEnter = Duration(milliseconds: 360);
  static const Duration pageExit = Duration(milliseconds: 300);

  static const Curve standard = Easing.standard;
  static const Curve standardAccelerate = Easing.standardAccelerate;
  static const Curve standardDecelerate = Easing.standardDecelerate;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedAccelerate = Easing.emphasizedAccelerate;
  static const Curve emphasizedDecelerate = Easing.emphasizedDecelerate;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve smooth = Easing.standard;
  static const Curve settle = Easing.emphasizedDecelerate;
  static const Curve pageIn = Easing.emphasizedDecelerate;
  static const Curve pageOut = Easing.emphasizedAccelerate;
  static const Curve spring = Curves.easeOutBack;

  static const AnimationStyle sheetEaseOut = AnimationStyle(
    curve: easeOut,
    reverseCurve: easeIn,
    duration: sheetEnter,
    reverseDuration: sheetExit,
  );
}
