import 'package:flutter_test/flutter_test.dart';
import 'package:medref/core/error/failure.dart';
import 'package:medref/data/repositories/medication_repository.dart';
import 'package:medref/data/services/openfda_api_client.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements OpenFdaApiClient {}

Map<String, dynamic> _rawLabel(String id) => {
  'set_id': id,
  'openfda': {
    'brand_name': ['Brand $id'],
    'generic_name': ['Generic $id'],
    'manufacturer_name': ['Manufacturer $id'],
  },
};

void main() {
  late _MockApiClient client;
  late MedicationRepository repository;

  setUp(() {
    client = _MockApiClient();
    repository = MedicationRepository(client: client);
  });

  group('fetchSummaries', () {
    test('flags hasMore true when a full page comes back', () async {
      when(
        () => client.fetchLabels(
          query: any(named: 'query'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => List.generate(
          MedicationRepository.pageSize,
          (i) => _rawLabel('$i'),
        ),
      );

      final page = await repository.fetchSummaries(skip: 0);

      expect(page.items, hasLength(MedicationRepository.pageSize));
      expect(page.items.first.setId, '0');
      expect(page.hasMore, isTrue);
    });

    test('flags hasMore false on a partial (final) page', () async {
      when(
        () => client.fetchLabels(
          query: any(named: 'query'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [_rawLabel('only')]);

      final page = await repository.fetchSummaries(skip: 40);

      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
    });

    test('propagates a Failure thrown by the api client', () {
      when(
        () => client.fetchLabels(
          query: any(named: 'query'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const Failure(FailureKind.rateLimit));

      expect(() => repository.fetchSummaries(skip: 0), throwsA(isA<Failure>()));
    });
  });

  group('fetchDetail', () {
    test('returns null when the api client finds no match', () async {
      when(() => client.fetchBySetId(any())).thenAnswer((_) async => null);

      expect(await repository.fetchDetail('missing'), isNull);
    });

    test('maps a found label into a MedicationDetail', () async {
      when(
        () => client.fetchBySetId(any()),
      ).thenAnswer((_) async => _rawLabel('found'));

      final detail = await repository.fetchDetail('found');

      expect(detail?.setId, 'found');
      expect(detail?.brandNames, ['Brand found']);
    });
  });
}
