import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

class _MyBilingualObject extends BilingualObject {
  _MyBilingualObject({
    super.nameEn,
    super.nameFr,
  });
}

void main() {
  test('test locale-based name', () {
    String nameEn = 'nameEn';
    String nameFr = 'nameFr';
    var myBilingualObject = _MyBilingualObject(
      nameEn: nameEn,
      nameFr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      BilingualObject.locale = 'fr-CA';
      expect(myBilingualObject.name, nameFr);
    });
    Intl.withLocale('en-CA', () {
      BilingualObject.locale = 'en-CA';
      expect(myBilingualObject.name, nameEn);
    });
    Intl.withLocale('es', () {
      BilingualObject.locale = 'es';
      expect(myBilingualObject.name, nameEn);
    });
  });

  test('test English name only', () {
    String nameEn = 'nameEn';
    var myBilingualObject = _MyBilingualObject(nameEn: nameEn);
    expect(myBilingualObject.name, nameEn);
  });

  test('test French name only', () {
    String nameFr = 'nameFr';
    var myBilingualObject = _MyBilingualObject(nameFr: nameFr);
    expect(myBilingualObject.name, nameFr);
  });

  test('test sortable name', () {
    String nameEn = 'nameEn';
    String nameFr = 'nameFr';
    var myBilingualObject = _MyBilingualObject(
      nameEn: nameEn,
      nameFr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      BilingualObject.locale = 'fr-CA';
      expect(
        myBilingualObject.sortableName,
        nameFr.replaceAll(RegExp('[\\W_]'), '').toUpperCase(),
      );
    });
    Intl.withLocale('en-CA', () {
      BilingualObject.locale = 'en-CA';
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
      nameEn: nameEn,
      nameFr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      BilingualObject.locale = 'fr-CA';
      expect(myBilingualObject.sortableName, 'NAMEFR');
    });
    Intl.withLocale('en-CA', () {
      BilingualObject.locale = 'en-CA';
      expect(myBilingualObject.sortableName, 'NAMEEN');
    });
  });
}
