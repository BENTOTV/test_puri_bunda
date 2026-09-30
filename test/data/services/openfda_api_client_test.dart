import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:medref/core/error/failure.dart';
import 'package:medref/data/services/openfda_api_client.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient httpClient;
  late OpenFdaApiClient api;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    api = OpenFdaApiClient(
      client: httpClient,
      // No real waiting for retry tests.
      rateLimitBackoffs: const [Duration.zero, Duration.zero, Duration.zero],
    );
  });

  http.Response jsonResponse(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status);

  group('fetchLabels', () {
    test('parses results on a 200 response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => jsonResponse({
          'results': [
            {
              'set_id': 'abc',
              'openfda': {
                'brand_name': ['Advil'],
              },
            },
          ],
        }),
      );

      final results = await api.fetchLabels(query: 'ibu', skip: 0, limit: 20);

      expect(results, hasLength(1));
      expect(results.first['set_id'], 'abc');
    });

    test('returns an empty list on 404 (openFDA "no matches")', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response('', 404));

      final results = await api.fetchLabels(skip: 0, limit: 20);

      expect(results, isEmpty);
    });

    test('throws a server Failure on 5xx', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response('', 503));

      expect(
        () => api.fetchLabels(skip: 0, limit: 20),
        throwsA(
          isA<Failure>().having((f) => f.kind, 'kind', FailureKind.server),
        ),
      );
    });

    test('throws a network Failure when the transport throws', () async {
      when(() => httpClient.get(any())).thenThrow(Exception('socket closed'));

      expect(
        () => api.fetchLabels(skip: 0, limit: 20),
        throwsA(
          isA<Failure>().having((f) => f.kind, 'kind', FailureKind.network),
        ),
      );
    });

    test('throws invalidData when the body has no results list', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => jsonResponse({'meta': {}}));

      expect(
        () => api.fetchLabels(skip: 0, limit: 20),
        throwsA(
          isA<Failure>().having((f) => f.kind, 'kind', FailureKind.invalidData),
        ),
      );
    });

    test('retries a 429 with backoff before giving up as rateLimit', () async {
      var callCount = 0;
      when(() => httpClient.get(any())).thenAnswer((_) async {
        callCount++;
        return http.Response('', 429);
      });

      await expectLater(
        api.fetchLabels(skip: 0, limit: 20),
        throwsA(
          isA<Failure>().having((f) => f.kind, 'kind', FailureKind.rateLimit),
        ),
      );
      // Initial attempt + one retry per configured backoff.
      expect(callCount, 4);
    });

    test('recovers if a 429 succeeds within the retry budget', () async {
      var callCount = 0;
      when(() => httpClient.get(any())).thenAnswer((_) async {
        callCount++;
        if (callCount < 2) return http.Response('', 429);
        return jsonResponse({'results': <Map<String, dynamic>>[]});
      });

      final results = await api.fetchLabels(skip: 0, limit: 20);

      expect(results, isEmpty);
      expect(callCount, 2);
    });
  });

  group('fetchBySetId', () {
    test('returns the first match', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => jsonResponse({
          'results': [
            {'set_id': 'xyz'},
          ],
        }),
      );

      final result = await api.fetchBySetId('xyz');

      expect(result?['set_id'], 'xyz');
    });

    test('returns null when nothing matches', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response('', 404));

      expect(await api.fetchBySetId('missing'), isNull);
    });
  });
}
