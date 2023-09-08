import 'package:flutter/material.dart' hide Action;

import 'action.dart';

class OverflowAction extends StatelessWidget {
  final Action action;

  const OverflowAction({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 25,
          child: Icon((action.icon), color: Colors.grey),
        ),
        Expanded(flex: 50, child: Text(action.tooltip)),
        Expanded(
          flex: 25,
          child: Visibility(
            visible: action.checked,
            child: const Icon(Icons.check_rounded, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
