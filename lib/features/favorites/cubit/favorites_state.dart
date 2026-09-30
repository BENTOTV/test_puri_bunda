import 'package:equatable/equatable.dart';

import '../../../data/models/medication_summary.dart';

class FavoritesState extends Equatable {
  const FavoritesState(this.items);

  const FavoritesState.empty() : items = const {};

  final Map<String, MedicationSummary> items;

  bool isFavorite(String setId) => items.containsKey(setId);

  int get count => items.length;

  List<MedicationSummary> get list => items.values.toList(growable: false);

  @override
  List<Object?> get props => [items];
}
