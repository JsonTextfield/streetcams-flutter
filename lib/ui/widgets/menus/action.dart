import 'package:flutter/material.dart';

final class Action {
  final IconData icon;
  final String tooltip;
  final bool condition;
  final bool checked;
  final Function()? onClick;
  final List<PopupMenuItem> popupMenuItems;

  const Action({
    required this.icon,
    required this.tooltip,
    this.condition = true,
    this.checked = false,
    this.onClick,
    this.popupMenuItems = const [],
  });
}
