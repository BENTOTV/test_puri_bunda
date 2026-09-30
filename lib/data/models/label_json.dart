/// Shared, defensive readers for the messy openFDA drug-label JSON shape.
///
/// Every field in a label can be missing, `null`, or hold several values —
/// the design system asks us to design for that rather than assume a shape.
library;

List<String> stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) => e?.toString().trim() ?? '')
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> openfdaOf(Map<String, dynamic> json) {
  final raw = json['openfda'];
  return raw is Map<String, dynamic> ? raw : const {};
}

/// `null` -> unknown, `'otc'` -> human OTC drug, `'rx'` -> prescription.
String? normalizedProductType(List<String> productType) {
  if (productType.isEmpty) return null;
  final joined = productType.join(' ').toUpperCase();
  if (joined.contains('OTC')) return 'otc';
  if (joined.contains('PRESCRIPTION')) return 'rx';
  return null;
}

DateTime? parseEffectiveTime(String? value) {
  if (value == null || value.length != 8) return null;
  final year = int.tryParse(value.substring(0, 4));
  final month = int.tryParse(value.substring(4, 6));
  final day = int.tryParse(value.substring(6, 8));
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}
