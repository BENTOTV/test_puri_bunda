import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication_summary.dart';

/// Persists favorited medications as card-field snapshots so the Favorites
/// tab works fully offline.
class FavoritesRepository {
  FavoritesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'medref.favorites.v1';

  List<MedicationSummary> getAll() {
    final raw = _prefs.getStringList(_key) ?? const [];
    return raw
        .map(
          (entry) => MedicationSummary.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }

  Future<void> add(MedicationSummary summary) async {
    final all = getAll();
    if (all.any((e) => e.setId == summary.setId)) return;
    await _persist([...all, summary]);
  }

  Future<void> remove(String setId) async {
    final all = getAll().where((e) => e.setId != setId).toList(growable: false);
    await _persist(all);
  }

  Future<void> _persist(List<MedicationSummary> all) {
    return _prefs.setStringList(
      _key,
      all.map((e) => jsonEncode(e.toJson())).toList(growable: false),
    );
  }
}
