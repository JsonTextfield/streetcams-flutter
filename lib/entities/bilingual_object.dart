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

  String get sortableName =>
      nameEn.replaceAll(RegExp('[\(\)]'), '').toUpperCase();

  String get name => Intl.getCurrentLocale().contains(fr) ? nameFr : nameEn;

  static String get appName => translate('appName');

  static const String en = 'en';
  static const String fr = 'fr';

  static String translate(String key) {
    if (_translations[key] != null) {
      var locale = Intl.getCurrentLocale().contains(fr) ? fr : en;
      return _translations[key]![locale] ?? '';
    }
    return '';
  }

  static const Map<String, Map<String, String>> _translations = {
    'appName': {
      en: 'StreetCams',
      fr: 'RueCams',
    },
    'clear': {
      en: 'Clear',
      fr: 'Dégager',
    },
    'shuffle': {
      en: 'Shuffle',
      fr: 'Mélanger',
    },
    'random': {
      en: 'Random',
      fr: 'Aléatoire',
    },
    'selectAll': {
      en: 'Select all',
      fr: 'Sélectionner toutes',
    },
    'about': {
      en: 'About',
      fr: 'À propos de',
    },
    'sortName': {
      en: 'Sort by name',
      fr: 'Trier par nom',
    },
    'sortDistance': {
      en: 'Sort by distance',
      fr: 'Trier par distance',
    },
    'list': {
      en: 'List',
      fr: 'Liste',
    },
    'map': {
      en: 'Map',
      fr: 'Carte',
    },
    'showCameras': {
      en: 'View',
      fr: 'Voir',
    },
    'hidden': {
      en: 'Hidden',
      fr: 'Cachées',
    },
    'favourites': {
      en: 'Favourites',
      fr: 'Favoris',
    },
    'error': {
      en: 'An error has occurred.',
      fr: 'Une erreur est survenue.',
    },
    'more': {
      en: 'More',
      fr: 'Plus',
    },
    'camera': {
      en: 'camera',
      fr: 'caméra',
    },
    'cameras': {
      en: 'cameras',
      fr: 'caméras',
    },
    'back': {
      en: 'Back',
      fr: 'Retourner',
    },
  };
}
