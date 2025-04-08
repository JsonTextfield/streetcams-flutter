import 'package:flutter/material.dart';

class CameraErrorWidget extends StatelessWidget {
  const CameraErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.videocam_off_rounded,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}
