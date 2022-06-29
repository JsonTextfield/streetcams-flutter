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

  String get sortableName => nameEn.replaceAll(RegExp('[\(\)]'), '').toUpperCase();

  String get name => Intl.getCurrentLocale().contains('fr') ? nameFr : nameEn;

  static String get appName =>
      Intl.getCurrentLocale().contains('fr') ? 'RueCams' : 'StreetCams';
}
