import 'package:intl/intl.dart';

class BilingualObject {
  final int id;
  final String nameEn;
  final String nameFr;

  const BilingualObject({
    required this.id,
    required this.nameEn,
    required this.nameFr,
  });

  String getSortableName() {
    return nameEn.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
  }

  String getName() {
    return Intl.getCurrentLocale().contains('fr') ? nameFr : nameEn;
  }

  static String getAppName() {
    return Intl.getCurrentLocale().contains('fr') ? 'RueCams' : 'StreetCams';
  }
}
