import 'package:flutter/material.dart' hide Action;

import 'action.dart';

class OverflowAction extends PopupMenuItem<Action> {
  final Action action;

  OverflowAction({
    super.key,
    required this.action,
  }) : super(
          padding: EdgeInsets.zero,
          value: action,
          child: Row(
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
          ),
        );
}
