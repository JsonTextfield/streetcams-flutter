import 'package:quiver/strings.dart';

abstract class BilingualObject {
  static String locale = 'en';
  final String nameEn;
  final String nameFr;

  const BilingualObject({
    this.nameEn = '',
    this.nameFr = '',
  });

  String get sortableName =>
      name.replaceAll(RegExp('[^0-9a-zA-Zà-öÀ-Ö]'), '').toUpperCase();

  String get name {
    if ((locale.contains('fr') && isNotBlank(nameFr)) || isBlank(nameEn)) {
      return nameFr;
    }
    return nameEn;
  }
}

extension StringExtensions on String {
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }
}
