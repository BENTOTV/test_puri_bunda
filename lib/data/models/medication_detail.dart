import 'package:equatable/equatable.dart';

import 'label_json.dart';
import 'medication_summary.dart';

class ActiveIngredient extends Equatable {
  const ActiveIngredient({required this.name, this.strength});

  final String name;
  final String? strength;

  static final _strengthPattern = RegExp(
    r'^(.*?)[\s,]+([\d.]+\s*(?:mg|mcg|g|mL|ml|%|units?)\b.*)$',
    caseSensitive: false,
  );

  factory ActiveIngredient.fromLabelLine(String line) {
    final match = _strengthPattern.firstMatch(line.trim());
    if (match == null) return ActiveIngredient(name: line.trim());
    return ActiveIngredient(
      name: match.group(1)!.trim(),
      strength: match.group(2)!.trim(),
    );
  }

  @override
  List<Object?> get props => [name, strength];
}

/// Full Medication Detail screen model, parsed defensively — every field on
/// a label can be missing or repeated.
class MedicationDetail extends Equatable {
  const MedicationDetail({
    required this.setId,
    required this.brandNames,
    required this.genericNames,
    required this.manufacturers,
    required this.productType,
    required this.activeIngredients,
    required this.purpose,
    required this.dosage,
    required this.warnings,
    required this.lastUpdated,
  });

  final String setId;
  final List<String> brandNames;
  final List<String> genericNames;
  final List<String> manufacturers;
  final String? productType;
  final List<ActiveIngredient> activeIngredients;
  final List<String> purpose;
  final List<String> dosage;
  final List<String> warnings;
  final DateTime? lastUpdated;

  /// Fallback tier between generic name and the "unavailable" placeholder
  /// — see [MedicationSummary.firstActiveIngredientName].
  String? get firstActiveIngredientName =>
      activeIngredients.isEmpty ? null : activeIngredients.first.name;

  factory MedicationDetail.fromLabelJson(Map<String, dynamic> json) {
    final openfda = openfdaOf(json);

    final ingredientLines = stringList(json['active_ingredient']);
    final ingredients =
        ingredientLines.isNotEmpty
            ? ingredientLines
                .map(ActiveIngredient.fromLabelLine)
                .toList(growable: false)
            : stringList(openfda['substance_name'])
                .map((name) => ActiveIngredient(name: name))
                .toList(growable: false);

    final warnings = stringList(json['warnings']);

    // OTC "Drug Facts" labels use `purpose`; prescription SPL labels use
    // `indications_and_usage` for the same "what this drug is for" role.
    final purpose = stringList(json['purpose']);

    return MedicationDetail(
      setId: json['set_id']?.toString() ?? json['id']?.toString() ?? '',
      brandNames: stringList(openfda['brand_name']),
      genericNames: stringList(openfda['generic_name']),
      manufacturers: stringList(openfda['manufacturer_name']),
      productType: normalizedProductType(stringList(openfda['product_type'])),
      activeIngredients: ingredients,
      purpose:
          purpose.isNotEmpty
              ? purpose
              : stringList(json['indications_and_usage']),
      dosage: stringList(json['dosage_and_administration']),
      warnings:
          warnings.isNotEmpty
              ? warnings
              : stringList(json['warnings_and_cautions']),
      lastUpdated: parseEffectiveTime(json['effective_time']?.toString()),
    );
  }

  MedicationSummary toSummary() => MedicationSummary(
    setId: setId,
    brandNames: brandNames,
    genericNames: genericNames,
    manufacturers: manufacturers,
    productType: productType,
    firstActiveIngredientName: firstActiveIngredientName,
  );

  @override
  List<Object?> get props => [
    setId,
    brandNames,
    genericNames,
    manufacturers,
    productType,
    activeIngredients,
    purpose,
    dosage,
    warnings,
    lastUpdated,
  ];
}
