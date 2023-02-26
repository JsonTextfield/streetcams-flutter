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

  String get sortableName => name.replaceAll(RegExp('[\\W_]'), '').toUpperCase();

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
    'search': {
      en: 'Search',
      fr: 'Chercher',
    },
    'sortName': {
      en: 'Sort by name',
      fr: 'Trier par nom',
    },
    'sortDistance': {
      en: 'Sort by distance',
      fr: 'Trier par distance',
    },
    'sortNeighbourhood': {
      en: 'Sort by neighbourhood',
      fr: 'Trier par quartier',
    },
    'sort': {
      en: 'Sort',
      fr: 'Trier',
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
    'hide': {
      en: 'Hide',
      fr: 'Cacher',
    },
    'unhide': {
      en: 'Unhide',
      fr: 'Afficher',
    },
    'favourites': {
      en: 'Favourites',
      fr: 'Favoris',
    },
    'favourite': {
      en: 'Favourite',
      fr: 'Favori',
    },
    'unfavourite': {
      en: 'Unfavourite',
      fr: 'Déconseillé',
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
    'searchCamera': {
      en: 'Search from %d camera',
      fr: 'Chercher de %d caméra',
    },
    'searchCameras': {
      en: 'Search from %d cameras',
      fr: 'Chercher de %d caméras',
    },
    'back': {
      en: 'Back',
      fr: 'Retourner',
    },
  };
}
