import 'package:intl/intl.dart';

abstract class BilingualObject {
  final int id;
  final String nameEn;
  final String nameFr;

  const BilingualObject({
    required this.id,
    required this.nameEn,
    required this.nameFr,
  });

  String get sortableName =>
      name.replaceAll(RegExp('[\\W_]'), '').toUpperCase();

  String get name => Intl.getCurrentLocale().contains('fr') ? nameFr : nameEn;
}
