import 'package:flutter/material.dart';
import 'package:zpevnik/utils/extensions.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(BuildContext, Widget)? wrapperBuilder;
  final Widget Function(BuildContext, Object?)? errorBuilder;
  final Widget Function(BuildContext, T?) builder;

  const CustomFutureBuilder({
    super.key,
    this.future,
    this.wrapperBuilder,
    this.errorBuilder,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final wrapperBuilder = this.wrapperBuilder ?? (_, child) => child;

    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.isDone) {
          if (snapshot.hasError) {
            return wrapperBuilder(context, errorBuilder?.call(context, snapshot.error) ?? Text('${snapshot.error}'));
          } else {
            return wrapperBuilder(context, builder(context, snapshot.data));
          }
        } else {
          return wrapperBuilder(context, const Center(child: CircularProgressIndicator.adaptive()));
        }
      },
    );
  }
}
