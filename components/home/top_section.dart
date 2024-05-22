import 'package:flutter/material.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/logo.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/utils/extensions.dart';

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2 / 3 * kDefaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Logo(showFullName: false),
          const Spacer(),
          Highlightable(
            onTap: () => context.push('/settings'),
            padding: const EdgeInsets.all(kDefaultPadding / 2),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
