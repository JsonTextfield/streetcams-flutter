// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/entities/Cities.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/widgets/camera_widget.dart';

void main() {
  testWidgets('test camera widget', (WidgetTester tester) async {
    Camera ottawaCamera = Camera.fromJson(
      {
        'number': 2025,
        'latitude': 45.341343,
        'description': '(MTO) Hwy 416 NB ramp to Hwy 417 East',
        'id': 309,
        'descriptionFr': '(MTO) Autoroute 416 bretelle vers autoroute 417 est',
        'type': 'MTO',
        'longitude': -75.81467,
      },
      Cities.ottawa,
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(CameraWidget(ottawaCamera));
    expect(find.text(ottawaCamera.name), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
