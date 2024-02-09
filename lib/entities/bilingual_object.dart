import 'package:quiver/strings.dart';

final class BilingualObject {
  static String locale = 'en';

  final String en;
  final String fr;

  const BilingualObject({
    this.en = '',
    this.fr = '',
  });

  String get sortableName =>
      name.toUpperCase().replaceAll(RegExp('[^0-9A-ZÀ-Ö]'), '');

  String get name =>
      (locale.contains('fr') && isNotBlank(fr)) || isBlank(en) ? fr : en;
}

extension StringExtensions on String {
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }
}
