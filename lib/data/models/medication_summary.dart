import 'package:equatable/equatable.dart';

import 'label_json.dart';
import 'medication_detail.dart' show ActiveIngredient;

/// One list row / favorite snapshot. Widgets take this, never raw JSON.
class MedicationSummary extends Equatable {
  const MedicationSummary({
    required this.setId,
    required this.brandNames,
    required this.genericNames,
    required this.manufacturers,
    required this.productType,
    this.firstActiveIngredientName,
  });

  final String setId;
  final List<String> brandNames;
  final List<String> genericNames;
  final List<String> manufacturers;

  /// `'otc'`, `'rx'`, or `null` when the label doesn't say.
  final String? productType;

  /// First active ingredient's name — a fallback tier between generic name
  /// and the "unavailable" placeholder: structured and short, unlike free
  /// text on the label (a real gap when `openfda` comes back empty).
  final String? firstActiveIngredientName;

  /// Whether openFDA's brand/generic/manufacturer/product-type enrichment
  /// was present at all for this label. Labels where it's empty are
  /// filtered out of the browse/search list (too little to identify the
  /// medication by) — see `ListScreen`.
  bool get hasOpenfdaData =>
      brandNames.isNotEmpty ||
      genericNames.isNotEmpty ||
      manufacturers.isNotEmpty ||
      productType != null;

  factory MedicationSummary.fromLabelJson(Map<String, dynamic> json) {
    final openfda = openfdaOf(json);

    final ingredientLines = stringList(json['active_ingredient']);
    final substanceNames = stringList(openfda['substance_name']);
    String? firstIngredientName;
    if (ingredientLines.isNotEmpty) {
      final name = ActiveIngredient.fromLabelLine(ingredientLines.first).name;
      firstIngredientName = name.isEmpty ? null : name;
    } else if (substanceNames.isNotEmpty) {
      firstIngredientName = substanceNames.first;
    }

    return MedicationSummary(
      setId: json['set_id']?.toString() ?? json['id']?.toString() ?? '',
      brandNames: stringList(openfda['brand_name']),
      genericNames: stringList(openfda['generic_name']),
      manufacturers: stringList(openfda['manufacturer_name']),
      productType: normalizedProductType(stringList(openfda['product_type'])),
      firstActiveIngredientName: firstIngredientName,
    );
  }

  factory MedicationSummary.fromJson(Map<String, dynamic> json) {
    return MedicationSummary(
      setId: json['setId'] as String? ?? '',
      brandNames: (json['brandNames'] as List?)?.cast<String>() ?? const [],
      genericNames: (json['genericNames'] as List?)?.cast<String>() ?? const [],
      manufacturers:
          (json['manufacturers'] as List?)?.cast<String>() ?? const [],
      productType: json['productType'] as String?,
      firstActiveIngredientName: json['firstActiveIngredientName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'setId': setId,
    'brandNames': brandNames,
    'genericNames': genericNames,
    'manufacturers': manufacturers,
    'productType': productType,
    'firstActiveIngredientName': firstActiveIngredientName,
  };

  @override
  List<Object?> get props => [
    setId,
    brandNames,
    genericNames,
    manufacturers,
    productType,
    firstActiveIngredientName,
  ];
}
