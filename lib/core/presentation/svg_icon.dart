import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon {
  static Widget asset(String path, {double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/$path.svg',
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
