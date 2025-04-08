import 'package:flutter/material.dart';

final class Action {
  final IconData icon;
  final String tooltip;
  final bool isVisible;
  final bool isChecked;
  final Function()? onClick;
  final List<Widget>? children;

  const Action({
    required this.icon,
    required this.tooltip,
    this.isVisible = true,
    this.isChecked = false,
    this.onClick,
    this.children,
  });
}
