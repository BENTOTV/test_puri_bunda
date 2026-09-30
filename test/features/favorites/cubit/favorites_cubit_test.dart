import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medref/data/models/medication_summary.dart';
import 'package:medref/data/repositories/favorites_repository.dart';
import 'package:medref/features/favorites/cubit/favorites_cubit.dart';
import 'package:medref/features/favorites/cubit/favorites_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late _MockFavoritesRepository repository;

  const summary = MedicationSummary(
    setId: 's1',
    brandNames: ['Advil'],
    genericNames: ['Ibuprofen'],
    manufacturers: ['Pfizer'],
    productType: 'otc',
  );

  setUpAll(() {
    registerFallbackValue(summary);
  });

  setUp(() {
    repository = _MockFavoritesRepository();
    when(() => repository.getAll()).thenReturn(const []);
  });

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle: adds optimistically and keeps it once persistence succeeds',
    build: () {
      when(() => repository.add(any())).thenAnswer((_) async {});
      return FavoritesCubit(repository);
    },
    act: (cubit) => cubit.toggle(summary),
    expect:
        () => [
          isA<FavoritesState>().having(
            (s) => s.isFavorite('s1'),
            'isFavorite',
            true,
          ),
        ],
    verify: (_) => verify(() => repository.add(summary)).called(1),
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle: rolls back the optimistic add when persistence fails',
    build: () {
      when(() => repository.add(any())).thenThrow(Exception('disk full'));
      return FavoritesCubit(repository);
    },
    act: (cubit) => cubit.toggle(summary),
    expect:
        () => [
          isA<FavoritesState>().having(
            (s) => s.isFavorite('s1'),
            'isFavorite',
            true,
          ),
          isA<FavoritesState>().having(
            (s) => s.isFavorite('s1'),
            'isFavorite',
            false,
          ),
        ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle: removes an already-favorited medication',
    seed: () => FavoritesState({summary.setId: summary}),
    build: () {
      when(() => repository.remove(any())).thenAnswer((_) async {});
      return FavoritesCubit(repository);
    },
    act: (cubit) => cubit.toggle(summary),
    expect:
        () => [
          isA<FavoritesState>().having(
            (s) => s.isFavorite('s1'),
            'isFavorite',
            false,
          ),
        ],
    verify: (_) => verify(() => repository.remove('s1')).called(1),
  );
}
