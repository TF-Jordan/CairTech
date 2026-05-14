import 'package:flutter/widgets.dart';

class BbcRadii {
  BbcRadii._();

  static const Radius sm = Radius.circular(6);
  static const Radius md = Radius.circular(10);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(22);
  static const Radius pill = Radius.circular(999);

  static const BorderRadius rSm = BorderRadius.all(sm);
  static const BorderRadius rMd = BorderRadius.all(md);
  static const BorderRadius rLg = BorderRadius.all(lg);
  static const BorderRadius rXl = BorderRadius.all(xl);
  static const BorderRadius rPill = BorderRadius.all(pill);
}

class BbcSpacing {
  BbcSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}
