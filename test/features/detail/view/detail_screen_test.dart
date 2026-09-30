import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medref/core/theme/app_theme.dart';
import 'package:medref/data/models/medication_detail.dart';
import 'package:medref/data/repositories/favorites_repository.dart';
import 'package:medref/data/repositories/medication_repository.dart';
import 'package:medref/features/detail/view/detail_screen.dart';
import 'package:medref/features/favorites/cubit/favorites_cubit.dart';
import 'package:medref/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

const _detail = MedicationDetail(
  setId: 'set-1',
  brandNames: ['Advil'],
  genericNames: ['Ibuprofen'],
  manufacturers: ['Pfizer'],
  productType: 'otc',
  activeIngredients: [],
  purpose: ['Relieves minor aches.'],
  dosage: ['Take one tablet every 4 hours.'],
  warnings: ['Do not exceed the recommended dose.'],
  lastUpdated: null,
);

Future<void> _pumpDetailScreen(
  WidgetTester tester, {
  required MedicationRepository repository,
  required FavoritesCubit favoritesCubit,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepositoryProvider<MedicationRepository>.value(
        value: repository,
        child: BlocProvider<FavoritesCubit>.value(
          value: favoritesCubit,
          child: const DetailScreen(setId: 'set-1'),
        ),
      ),
    ),
  );
}

void main() {
  late _MockMedicationRepository repository;
  late _MockFavoritesRepository favoritesRepository;
  late FavoritesCubit favoritesCubit;

  setUpAll(() {
    registerFallbackValue(_detail.toSummary());
  });

  setUp(() {
    repository = _MockMedicationRepository();
    favoritesRepository = _MockFavoritesRepository();
    when(() => favoritesRepository.getAll()).thenReturn(const []);
    when(() => favoritesRepository.add(any())).thenAnswer((_) async {});
    when(() => favoritesRepository.remove(any())).thenAnswer((_) async {});
    favoritesCubit = FavoritesCubit(favoritesRepository);

    when(
      () => repository.fetchDetail('set-1'),
    ).thenAnswer((_) async => _detail);
  });

  testWidgets('favorite toggle round-trip in the detail app bar', (
    tester,
  ) async {
    await _pumpDetailScreen(
      tester,
      repository: repository,
      favoritesCubit: favoritesCubit,
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Advil'), findsOneWidget);
    expect(find.byIcon(LucideIcons.heart), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    await tester.tap(find.byIcon(LucideIcons.heart));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(LucideIcons.heart), findsNothing);
    verify(() => favoritesRepository.add(any())).called(1);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.heart), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
    verify(() => favoritesRepository.remove('set-1')).called(1);
  });
}
