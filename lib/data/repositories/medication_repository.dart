import '../models/medication_detail.dart';
import '../models/medication_summary.dart';
import '../services/openfda_api_client.dart';

class MedicationPage {
  const MedicationPage({required this.items, required this.hasMore});

  final List<MedicationSummary> items;
  final bool hasMore;
}

/// Talks to openFDA and turns raw label JSON into presentation models.
class MedicationRepository {
  MedicationRepository({OpenFdaApiClient? client})
    : _client = client ?? OpenFdaApiClient();

  final OpenFdaApiClient _client;

  static const pageSize = 20;

  Future<MedicationPage> fetchSummaries({
    String? query,
    required int skip,
  }) async {
    final raw = await _client.fetchLabels(
      query: query,
      skip: skip,
      limit: pageSize,
    );
    return MedicationPage(
      items: raw.map(MedicationSummary.fromLabelJson).toList(growable: false),
      hasMore: raw.length == pageSize,
    );
  }

  Future<MedicationDetail?> fetchDetail(String setId) async {
    final raw = await _client.fetchBySetId(setId);
    return raw == null ? null : MedicationDetail.fromLabelJson(raw);
  }

  void dispose() => _client.dispose();
}
