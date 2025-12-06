import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;

  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.elevation = 1.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
