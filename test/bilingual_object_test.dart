import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

class _MyBilingualObject extends BilingualObject {
  _MyBilingualObject(
      {required super.id, required super.nameEn, required super.nameFr});
}

void main() {
  test('test locale-based name', () {
    String nameEn = 'nameEn';
    String nameFr = 'nameFr';
    var myBilingualObject = _MyBilingualObject(
      id: 0,
      nameEn: nameEn,
      nameFr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      expect(myBilingualObject.name, nameFr);
    });
    Intl.withLocale('en-CA', () {
      expect(myBilingualObject.name, nameEn);
    });
    Intl.withLocale('es', () {
      expect(myBilingualObject.name, nameEn);
    });
  });

  test('test sortable name', () {
    String nameEn = 'nameEn';
    String nameFr = 'nameFr';
    var myBilingualObject = _MyBilingualObject(
      id: 0,
      nameEn: nameEn,
      nameFr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      expect(
        myBilingualObject.sortableName,
        nameFr.replaceAll(RegExp('[\\W_]'), '').toUpperCase(),
      );
    });
    Intl.withLocale('en-CA', () {
      expect(
        myBilingualObject.sortableName,
        nameEn.replaceAll(RegExp('[\\W_]'), '').toUpperCase(),
      );
    });
  });

  test('test sortable name special characters', () {
    String nameEn =
        'n~!@#\$%^&*()+_a~!@#\$%^&*()+_m~!@#\$%^&*()+_e~!@#\$%^&*()+_E~!@#\$%^&*()+_n';
    String nameFr =
        'n~!@#\$%^&*()+_a~!@#\$%^&*()+_m~!@#\$%^&*()+_e~!@#\$%^&*()+_F~!@#\$%^&*()+_r';
    var myBilingualObject = _MyBilingualObject(
      id: 0,
      nameEn: nameEn,
      nameFr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      expect(myBilingualObject.sortableName, 'NAMEFR');
    });
    Intl.withLocale('en-CA', () {
      expect(myBilingualObject.sortableName, 'NAMEEN');
    });
  });
}
