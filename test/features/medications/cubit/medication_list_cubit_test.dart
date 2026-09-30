import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medref/core/error/failure.dart';
import 'package:medref/data/models/medication_summary.dart';
import 'package:medref/data/repositories/medication_repository.dart';
import 'package:medref/data/services/openfda_api_client.dart';
import 'package:medref/features/medications/cubit/medication_list_cubit.dart';
import 'package:medref/features/medications/cubit/medication_list_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements OpenFdaApiClient {}

void main() {
  late _MockApiClient client;
  late MedicationRepository repository;

  const summary = MedicationSummary(
    setId: 's1',
    brandNames: ['Advil'],
    genericNames: ['Ibuprofen'],
    manufacturers: ['Pfizer'],
    productType: 'otc',
  );

  setUp(() {
    client = _MockApiClient();
    repository = MedicationRepository(client: client);
  });

  void stubFetch({List<Map<String, dynamic>>? results, Failure? failure}) {
    final call = when(
      () => client.fetchLabels(
        query: any(named: 'query'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
    if (failure != null) {
      call.thenThrow(failure);
    } else {
      call.thenAnswer((_) async => results ?? const []);
    }
  }

  blocTest<MedicationListCubit, MedicationListState>(
    'retryFirstLoad: Loading -> Success',
    build: () {
      stubFetch(
        results: [
          {
            'set_id': summary.setId,
            'openfda': {
              'brand_name': summary.brandNames,
              'generic_name': summary.genericNames,
              'manufacturer_name': summary.manufacturers,
              'product_type': ['HUMAN OTC DRUG'],
            },
          },
        ],
      );
      return MedicationListCubit(repository);
    },
    act: (cubit) => cubit.retryFirstLoad(),
    expect:
        () => [
          isA<MedicationListState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.items, 'items', isEmpty),
          isA<MedicationListState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.items, 'items', [summary])
              .having((s) => s.firstLoadFailure, 'firstLoadFailure', isNull),
        ],
  );

  blocTest<MedicationListCubit, MedicationListState>(
    'retryFirstLoad: Loading -> Error',
    build: () {
      stubFetch(failure: const Failure(FailureKind.network));
      return MedicationListCubit(repository);
    },
    act: (cubit) => cubit.retryFirstLoad(),
    expect:
        () => [
          isA<MedicationListState>().having(
            (s) => s.isLoading,
            'isLoading',
            true,
          ),
          isA<MedicationListState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.firstLoadFailure?.kind,
                'firstLoadFailure.kind',
                FailureKind.network,
              ),
        ],
  );

  blocTest<MedicationListCubit, MedicationListState>(
    'below the 2-char minimum updates the query without calling the API',
    build: () {
      stubFetch(results: const []);
      return MedicationListCubit(repository);
    },
    act: (cubit) => cubit.onSearchChanged('a'),
    expect:
        () => [
          isA<MedicationListState>()
              .having((s) => s.query, 'query', 'a')
              .having(
                (s) => s.belowMinQueryLength,
                'belowMinQueryLength',
                true,
              ),
        ],
    verify: (_) {
      verifyNever(
        () => client.fetchLabels(
          query: any(named: 'query'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    },
  );
}
