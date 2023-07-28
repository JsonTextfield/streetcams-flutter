import 'package:flutter/material.dart' hide Action;

import 'action.dart';

class MenuAction extends StatelessWidget {
  final Action action;

  const MenuAction({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return action.child ?? Icon(action.icon);
  }
}
