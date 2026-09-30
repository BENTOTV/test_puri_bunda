import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/error/failure.dart';

/// Thin HTTP wrapper over the public openFDA drug-label endpoint.
///
/// Maps transport/HTTP outcomes to the 4 [Failure] kinds the design system
/// defines, retrying a 429 with exponential backoff (1s -> 2s -> 4s) before
/// surfacing [FailureKind.rateLimit].
class OpenFdaApiClient {
  OpenFdaApiClient({http.Client? client, List<Duration>? rateLimitBackoffs})
    : _client = client ?? http.Client(),
      _rateLimitBackoffs = rateLimitBackoffs ?? _defaultRateLimitBackoffs;

  final http.Client _client;
  final List<Duration> _rateLimitBackoffs;

  static const _base = 'https://api.fda.gov/drug/label.json';
  static const _defaultRateLimitBackoffs = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  Future<List<Map<String, dynamic>>> fetchLabels({
    String? query,
    required int skip,
    required int limit,
  }) {
    final uri = Uri.parse(_base).replace(
      queryParameters: {
        if (query != null && query.trim().isNotEmpty)
          'search': _searchExpression(query.trim()),
        'limit': '$limit',
        'skip': '$skip',
      },
    );
    return _getResults(uri);
  }

  /// Fetches the one label matching `set_id`, used both for opening a
  /// detail screen and refreshing a saved Favorites snapshot when online.
  Future<Map<String, dynamic>?> fetchBySetId(String setId) async {
    final uri = Uri.parse(
      _base,
    ).replace(queryParameters: {'search': 'set_id:"$setId"', 'limit': '1'});
    final results = await _getResults(uri);
    return results.isEmpty ? null : results.first;
  }

  String _searchExpression(String query) {
    final escaped = query.replaceAll('"', '');
    return 'openfda.brand_name:"$escaped*" OR openfda.generic_name:"$escaped*"';
  }

  Future<List<Map<String, dynamic>>> _getResults(Uri uri) async {
    for (var attempt = 0; ; attempt++) {
      final http.Response response;
      try {
        response = await _client.get(uri);
      } on Exception {
        throw const Failure(FailureKind.network);
      }

      switch (response.statusCode) {
        case 200:
          final body = _decode(response.body);
          final results = body['results'];
          if (results is! List) throw const Failure(FailureKind.invalidData);
          return results.cast<Map<String, dynamic>>();
        case 404:
          // openFDA returns 404 for "no matches" — that's an empty result,
          // not a failure.
          return const [];
        case 429:
          if (attempt < _rateLimitBackoffs.length) {
            await Future.delayed(_rateLimitBackoffs[attempt]);
            continue;
          }
          throw Failure(
            FailureKind.rateLimit,
            retryAfter: _rateLimitBackoffs.last,
          );
        default:
          if (response.statusCode >= 500) {
            throw const Failure(FailureKind.server);
          }
          throw const Failure(FailureKind.invalidData);
      }
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const Failure(FailureKind.invalidData);
    } on FormatException {
      throw const Failure(FailureKind.invalidData);
    }
  }

  void dispose() => _client.close();
}
