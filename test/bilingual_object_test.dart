import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

void main() {
  test('test locale-based name', () {
    String nameEn = 'nameEn';
    String nameFr = 'nameFr';
    var myBilingualObject = BilingualObject(
      en: nameEn,
      fr: nameFr,
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
    var myBilingualObject = BilingualObject(en: nameEn);
    expect(myBilingualObject.name, nameEn);
  });

  test('test French name only', () {
    String nameFr = 'nameFr';
    var myBilingualObject = BilingualObject(fr: nameFr);
    expect(myBilingualObject.name, nameFr);
  });

  test('test sortable name', () {
    String nameEn = 'nameEn';
    String nameFr = 'nameFr';
    var myBilingualObject = BilingualObject(
      en: nameEn,
      fr: nameFr,
    );
    Intl.getCurrentLocale();
    Intl.withLocale('fr-CA', () {
      BilingualObject.locale = 'fr-CA';
      expect(
        myBilingualObject.sortableName,
        nameFr.replaceAll(RegExp('[^0-9a-zA-Zà-öÀ-Ö]'), '').toUpperCase(),
      );
    });
    Intl.withLocale('en-CA', () {
      BilingualObject.locale = 'en-CA';
      expect(
        myBilingualObject.sortableName,
        nameEn.replaceAll(RegExp('[^0-9a-zA-Zà-öÀ-Ö]'), '').toUpperCase(),
      );
    });
  });

  test('test sortable name special characters', () {
    var myBilingualObject = const BilingualObject(
      en: 'n~!@#\$%^&*()+_a~!@#\$%^&*()+_m~!@#\$%^&*()+_e~!@#\$%^&*()+_E~!@#\$%^&*()+_n',
      fr: 'n~!@#\$%^&*()+_a~!@#\$%^&*()+_m~!@#\$%^&*()+_e~!@#\$%^&*()+_F~!@#\$%^&*()+_r',
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
