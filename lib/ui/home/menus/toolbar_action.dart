import 'package:flutter/material.dart' hide Action;

import 'action.dart';

class ToolbarAction extends StatelessWidget {
  final Action action;

  const ToolbarAction({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return action.isVisible
        ? IconButton(
            onPressed: action.onClick,
            icon: Icon(action.icon),
            tooltip: action.tooltip,
          )
        : const SizedBox.shrink();
  }
}
