import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medref/core/theme/app_theme.dart';
import 'package:medref/data/models/medication_summary.dart';
import 'package:medref/data/repositories/favorites_repository.dart';
import 'package:medref/data/repositories/medication_repository.dart';
import 'package:medref/features/favorites/cubit/favorites_cubit.dart';
import 'package:medref/features/medications/view/list_screen.dart';
import 'package:medref/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

MedicationSummary _summary(String id, {String brand = 'Brand'}) =>
    MedicationSummary(
      setId: id,
      brandNames: [brand],
      genericNames: const [],
      manufacturers: const [],
      productType: 'otc',
    );

Future<void> _pumpListScreen(
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
          child: const ListScreen(),
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
    registerFallbackValue(_summary('fallback'));
  });

  setUp(() {
    repository = _MockMedicationRepository();
    favoritesRepository = _MockFavoritesRepository();
    when(() => favoritesRepository.getAll()).thenReturn(const []);
    when(() => favoritesRepository.add(any())).thenAnswer((_) async {});
    when(() => favoritesRepository.remove(any())).thenAnswer((_) async {});
    favoritesCubit = FavoritesCubit(favoritesRepository);
  });

  testWidgets(
    'debounces search: no fetch before 400ms, exactly one fetch after',
    (tester) async {
      when(() => repository.fetchSummaries(query: null, skip: 0)).thenAnswer(
        (_) async => const MedicationPage(items: [], hasMore: false),
      );
      when(() => repository.fetchSummaries(query: 'ibu', skip: 0)).thenAnswer(
        (_) async => MedicationPage(
          items: [_summary('ibu-1', brand: 'Advil')],
          hasMore: false,
        ),
      );

      await _pumpListScreen(
        tester,
        repository: repository,
        favoritesCubit: favoritesCubit,
      );
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'ibu');
      await tester.pump();
      verifyNever(() => repository.fetchSummaries(query: 'ibu', skip: 0));

      // Still within the 400ms debounce window — no fetch yet.
      await tester.pump(const Duration(milliseconds: 399));
      verifyNever(() => repository.fetchSummaries(query: 'ibu', skip: 0));

      // Crosses the debounce window — exactly one fetch now.
      await tester.pump(const Duration(milliseconds: 50));
      verify(() => repository.fetchSummaries(query: 'ibu', skip: 0)).called(1);

      await tester.pump();
      expect(find.text('Advil'), findsOneWidget);
    },
  );

  testWidgets('scrolling near the end triggers pagination (loadMore)', (
    tester,
  ) async {
    final firstPage = List.generate(
      20,
      (i) => _summary('id-$i', brand: 'Brand $i'),
    );
    when(
      () => repository.fetchSummaries(query: null, skip: 0),
    ).thenAnswer((_) async => MedicationPage(items: firstPage, hasMore: true));
    when(() => repository.fetchSummaries(query: null, skip: 20)).thenAnswer(
      (_) async => MedicationPage(
        items: [_summary('id-20', brand: 'Brand 20')],
        hasMore: false,
      ),
    );

    await _pumpListScreen(
      tester,
      repository: repository,
      favoritesCubit: favoritesCubit,
    );
    await tester.pump();
    await tester.pump();

    verifyNever(() => repository.fetchSummaries(query: null, skip: 20));

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pump();
    await tester.pump();

    verify(() => repository.fetchSummaries(query: null, skip: 20)).called(1);
  });

  testWidgets('favorite toggle round-trip on a list card', (tester) async {
    when(() => repository.fetchSummaries(query: null, skip: 0)).thenAnswer(
      (_) async => MedicationPage(
        items: [_summary('fav-1', brand: 'Advil')],
        hasMore: false,
      ),
    );

    await _pumpListScreen(
      tester,
      repository: repository,
      favoritesCubit: favoritesCubit,
    );
    await tester.pump();
    await tester.pump();

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
    verify(() => favoritesRepository.remove('fav-1')).called(1);
  });
}
