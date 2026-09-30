// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'MedRef';

  @override
  String get medicationsTitle => 'Obat';

  @override
  String get favoritesTitle => 'Favorit';

  @override
  String get searchHint => 'Cari nama merek atau generik';

  @override
  String get searchMinChars => 'Ketik minimal 2 karakter untuk mencari';

  @override
  String get unknownManufacturer => 'Produsen tidak diketahui';

  @override
  String get brandUnavailable => 'Nama merek tidak tersedia';

  @override
  String moreValues(int count) {
    return '+$count lainnya';
  }

  @override
  String get sectionPurpose => 'Kegunaan';

  @override
  String get sectionDosage => 'Dosis';

  @override
  String get sectionWarnings => 'Peringatan';

  @override
  String get sectionActiveIngredients => 'Bahan aktif';

  @override
  String get notProvided => 'Tidak tercantum pada label ini.';

  @override
  String get showMore => 'Tampilkan lebih banyak';

  @override
  String get showLess => 'Tampilkan lebih sedikit';

  @override
  String get emptySearchTitle => 'Obat tidak ditemukan';

  @override
  String emptySearchBody(String query) {
    return 'Tidak ada yang cocok dengan “$query”. Periksa ejaan atau coba nama generik.';
  }

  @override
  String get errorNetworkTitle => 'Tidak dapat terhubung';

  @override
  String get errorNetworkBody =>
      'Periksa koneksi internet Anda lalu coba lagi.';

  @override
  String get errorServerTitle => 'Terjadi kesalahan';

  @override
  String get errorServerBody => 'Silakan coba lagi sesaat lagi.';

  @override
  String get errorRateLimitTitle => 'Terlalu banyak permintaan';

  @override
  String get errorRateLimitBody =>
      'openFDA sedang membatasi permintaan. Mohon tunggu sebentar.';

  @override
  String get errorInvalidDataTitle => 'Terjadi kesalahan';

  @override
  String get errorInvalidDataBody =>
      'Kami tidak dapat membaca data ini. Silakan coba lagi.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get favoritesEmptyTitle => 'Belum ada favorit';

  @override
  String get favoritesEmptyBody =>
      'Ketuk ikon hati pada obat mana pun untuk menyimpannya di sini, bahkan saat offline.';

  @override
  String get browseMedications => 'Jelajahi obat';

  @override
  String get clearSearch => 'Hapus pencarian';

  @override
  String get addFavorite => 'Tambah ke favorit';

  @override
  String get removeFavorite => 'Hapus dari favorit';

  @override
  String get removedSnack => 'Dihapus dari favorit';

  @override
  String get undo => 'Urungkan';

  @override
  String get disclaimer =>
      'Hanya untuk referensi. Data berasal dari basis data label openFDA publik dan bukan saran medis.';

  @override
  String get otcBadge => 'OTC';

  @override
  String get rxBadge => 'Rx';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get language => 'Bahasa';

  @override
  String lastUpdated(String date) {
    return 'Terakhir diperbarui $date';
  }
}
