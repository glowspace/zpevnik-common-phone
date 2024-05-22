import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/navigation/navigation_rail.dart';
import 'package:zpevnik/providers/display_screen_status.dart';
import 'package:zpevnik/utils/extensions.dart';

class NavigationRailWrapper extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final bool showNavigationRail;

  const NavigationRailWrapper({super.key, required this.builder, required this.showNavigationRail});

  @override
  Widget build(BuildContext context) {
    if (showNavigationRail && MediaQuery.of(context).isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // make the widget display from right to left, so the navigation rail shadow is visible
        textDirection: TextDirection.rtl,
        children: [
          Expanded(child: builder(context)),
          Consumer(
            builder: (_, ref, child) => ref.watch(displayScreenStatusProvider.select((status) => status.fullScreen))
                ? const SizedBox()
                : child!,
            child: const CustomNavigationRail(),
          ),
        ],
      );
    }

    return builder(context);
  }
}
