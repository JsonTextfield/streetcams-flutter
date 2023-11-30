import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/ui/street_cams_app.dart';

void main() {
  testWidgets('test app bar displayed children', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreetCamsApp());
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('StreetCams'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.pump(const Duration(seconds: 5));

      //expect(find.byTooltip('More'), findsOneWidget);
      //expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      expect(find.byTooltip('City'), findsOneWidget);
      expect(find.byIcon(Icons.location_city_rounded), findsOneWidget);

      //await tester.longPress(find.byType(ScrollablePositionedList));
      //expect(find.text('1 camera selected'), findsOneWidget);
    });
  });
}
