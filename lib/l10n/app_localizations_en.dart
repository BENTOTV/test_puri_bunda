// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedRef';

  @override
  String get medicationsTitle => 'Medications';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get searchHint => 'Search brand or generic name';

  @override
  String get searchMinChars => 'Type at least 2 characters to search';

  @override
  String get unknownManufacturer => 'Unknown manufacturer';

  @override
  String get brandUnavailable => 'Brand name unavailable';

  @override
  String moreValues(int count) {
    return '+$count more';
  }

  @override
  String get sectionPurpose => 'Purpose';

  @override
  String get sectionDosage => 'Dosage';

  @override
  String get sectionWarnings => 'Warnings';

  @override
  String get sectionActiveIngredients => 'Active ingredients';

  @override
  String get notProvided => 'Not provided in this label.';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get emptySearchTitle => 'No medications found';

  @override
  String emptySearchBody(String query) {
    return 'Nothing matches “$query”. Check the spelling or try a generic name.';
  }

  @override
  String get errorNetworkTitle => 'Can’t connect';

  @override
  String get errorNetworkBody =>
      'Check your internet connection and try again.';

  @override
  String get errorServerTitle => 'Something went wrong';

  @override
  String get errorServerBody => 'Please try again in a moment.';

  @override
  String get errorRateLimitTitle => 'Too many requests';

  @override
  String get errorRateLimitBody =>
      'openFDA is limiting requests right now. Please wait a moment.';

  @override
  String get errorInvalidDataTitle => 'Something went wrong';

  @override
  String get errorInvalidDataBody =>
      'We couldn’t read this data. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on any medication to keep it here, even offline.';

  @override
  String get browseMedications => 'Browse medications';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get removedSnack => 'Removed from favorites';

  @override
  String get undo => 'Undo';

  @override
  String get disclaimer =>
      'For reference only. Data comes from the public openFDA label database and is not medical advice.';

  @override
  String get otcBadge => 'OTC';

  @override
  String get rxBadge => 'Rx';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get language => 'Language';

  @override
  String lastUpdated(String date) {
    return 'Last updated $date';
  }
}
