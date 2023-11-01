// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/location.dart';
import 'package:streetcams_flutter/ui/widgets/camera_widget.dart';

void main() {
  testWidgets('test camera widget', (WidgetTester tester) async {
    Camera ottawaCamera = Camera(
      city: City.ottawa,
      nameEn: 'Bank & Heron',
      nameFr: 'Bank et Heron',
      neighbourhood: 'Alta Vista',
      url: 'https://traffic.ottawa.ca/beta/camera?id=81',
      location: const Location(
        lat: 45.4545,
        lon: -75.6969,
      ),
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: CameraWidget(ottawaCamera),
    ));
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text(ottawaCamera.name), findsOneWidget);
  });
}
