import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';

const Color lightBackgroundColor = Color(0xfff2f1f6);
const Color darkBackgroundColor = Color(0xff000000);

const Color lightTitleColor = Color(0xff3d3636);
const Color darkTitleColor = Color(0xffc2c9c9);

const Color lightTextColor = Color(0xff282828);
const Color darkTextColor = Color(0xffd7d7d7);

const Color lightCommentColor = Color(0xff827c7c);
const Color darkCommentColor = Color(0xff7d8383);

const Color lightCaptionColor = Color(0xffa6a6a6);
const Color darkCaptionColor = Color(0xff595959);

const Color lightIconColor = Color(0xff595959);
const Color darkIconColor = Color(0xffa6a6a6);

const Color lightDividerColor = Color(0xfff5f5f8);
const Color darkDividerColor = Color(0xff282839);

const Color lightShadowColor = Color(0xfff3edf7);
const Color darkShadowColor = Color(0xff341d43);

class AppTheme {
  static ThemeData light(Color seedColor) {
    const iconTheme = IconThemeData(color: lightIconColor);

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, background: lightBackgroundColor),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        iconTheme: iconTheme,
        shadowColor: lightShadowColor,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, color: lightTextColor, fontWeight: FontWeight.w400),
        titleSpacing: 1.25 * kDefaultPadding,
        elevation: 1,
      ),
      dividerTheme: const DividerThemeData(space: 0, thickness: 1.5, color: lightDividerColor),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, color: lightTextColor, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 17, color: lightTextColor, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, color: lightTextColor, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 15, color: lightTextColor, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 14, color: lightCaptionColor, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, color: lightCommentColor, fontWeight: FontWeight.w400),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius))),
      ),
      splashFactory: NoSplash.splashFactory,
      iconTheme: iconTheme,
      useMaterial3: true,
    );
  }

  static ThemeData dark(Color seedColor) {
    const iconTheme = IconThemeData(color: darkIconColor);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        background: darkBackgroundColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        iconTheme: iconTheme,
        shadowColor: darkShadowColor,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, color: darkTextColor, fontWeight: FontWeight.w400),
        titleSpacing: 1.25 * kDefaultPadding,
        elevation: 1,
      ),
      dividerTheme: const DividerThemeData(space: 0, thickness: 1.5, color: darkDividerColor),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, color: darkTextColor, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 17, color: darkTextColor, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, color: darkTextColor, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 15, color: darkTextColor, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 14, color: darkCaptionColor, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, color: darkCommentColor, fontWeight: FontWeight.w400),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius))),
      ),
      splashFactory: NoSplash.splashFactory,
      // needed, so text in alert dialogs on iOS has correct color
      cupertinoOverrideTheme: const CupertinoThemeData(textTheme: CupertinoTextThemeData()),
      iconTheme: iconTheme,
      useMaterial3: true,
    );
  }
}
