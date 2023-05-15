import 'package:quiver/strings.dart';

abstract class BilingualObject {
  static String locale = 'en';
  final int id;
  final String nameEn;
  final String nameFr;

  const BilingualObject({
    this.id = 0,
    this.nameEn = '',
    this.nameFr = '',
  });

  String get sortableName =>
      name.replaceAll(RegExp('[\\W_]'), '').toUpperCase();

  String get name {
    if ((locale.contains('fr') && isNotBlank(nameFr)) || isBlank(nameEn)) {
      return nameFr;
    }
    return nameEn;
  }
}
