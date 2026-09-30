import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/medication_summary.dart';
import '../../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';

/// Optimistic favorite toggling: the UI updates immediately, the change is
/// persisted in the background, and rolled back if persistence throws.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository)
    : super(FavoritesState({for (final s in _repository.getAll()) s.setId: s}));

  final FavoritesRepository _repository;

  bool isFavorite(String setId) => state.isFavorite(setId);

  Future<void> toggle(MedicationSummary summary) {
    return state.isFavorite(summary.setId)
        ? remove(summary.setId)
        : _add(summary);
  }

  Future<void> _add(MedicationSummary summary) async {
    final previous = state;
    emit(FavoritesState({...previous.items, summary.setId: summary}));
    try {
      await _repository.add(summary);
    } catch (_) {
      emit(previous);
    }
  }

  Future<void> remove(String setId) async {
    final previous = state;
    final next = Map.of(previous.items)..remove(setId);
    emit(FavoritesState(next));
    try {
      await _repository.remove(setId);
    } catch (_) {
      emit(previous);
    }
  }
}
