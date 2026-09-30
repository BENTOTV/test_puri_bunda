import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/error/failure_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/med_ref_colors.dart';
import '../../../data/models/medication_summary.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/detail_section.dart';
import '../../../widgets/disclaimer_banner.dart';
import '../../../widgets/favorite_button.dart';
import '../../../widgets/ingredient_tag.dart';
import '../../../widgets/state_view.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../../favorites/cubit/favorites_state.dart';
import '../cubit/detail_cubit.dart';
import '../cubit/detail_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.setId, this.seed, super.key});

  final String setId;
  final MedicationSummary? seed;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final DetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DetailCubit(
      context.read<MedicationRepository>(),
      setId: widget.setId,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.medRefColors;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const SizedBox.shrink(),
          actions: [
            BlocBuilder<DetailCubit, DetailState>(
              builder: (context, state) {
                final summary = state.detail?.toSummary() ?? widget.seed;
                if (summary == null) return const SizedBox.shrink();
                return BlocBuilder<FavoritesCubit, FavoritesState>(
                  buildWhen:
                      (a, b) =>
                          a.isFavorite(summary.setId) !=
                          b.isFavorite(summary.setId),
                  builder: (context, favState) {
                    return FavoriteButton(
                      isFavorite: favState.isFavorite(summary.setId),
                      onToggle:
                          () => context.read<FavoritesCubit>().toggle(summary),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: AppSpacing.s2),
          ],
        ),
        body: BlocBuilder<DetailCubit, DetailState>(
          builder: (context, state) {
            if (state.detail == null && state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.detail == null && state.failure != null) {
              return StateView.failure(
                context,
                presentation: presentFailure(state.failure!, l10n),
                buttonLabel: l10n.retry,
                onButtonPressed: _cubit.load,
              );
            }

            final detail = state.detail!;
            final hasBrand = detail.brandNames.isNotEmpty;
            final hasGeneric = detail.genericNames.isNotEmpty;
            final ingredientName = detail.firstActiveIngredientName;
            final hasIngredientName =
                ingredientName != null && ingredientName.isNotEmpty;

            final String headline =
                hasBrand
                    ? detail.brandNames.first
                    : hasGeneric
                    ? detail.genericNames.first
                    : hasIngredientName
                    ? ingredientName
                    : l10n.brandUnavailable;
            final headlineIsFallback =
                !hasBrand && !hasGeneric && !hasIngredientName;
            final showGenericLine = hasBrand && hasGeneric;

            final badgeLabel = switch (detail.productType) {
              'otc' => l10n.otcBadge,
              'rx' => l10n.rxBadge,
              _ => null,
            };

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s4,
                0,
                AppSpacing.s4,
                AppSpacing.s8,
              ),
              children: [
                if (badgeLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                    child: Text(
                      badgeLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: tokens.inkMuted),
                    ),
                  ),
                Text(
                  headline,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: headlineIsFallback ? tokens.inkMuted : null,
                    fontStyle:
                        headlineIsFallback
                            ? FontStyle.italic
                            : FontStyle.normal,
                  ),
                ),
                if (showGenericLine) ...[
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    detail.genericNames.first,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: tokens.inkMuted),
                  ),
                ],
                const SizedBox(height: AppSpacing.s1),
                Text(
                  detail.manufacturers.isNotEmpty
                      ? detail.manufacturers.first
                      : l10n.unknownManufacturer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.inkMuted,
                    fontStyle:
                        detail.manufacturers.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                  ),
                ),
                if (detail.activeIngredients.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    l10n.sectionActiveIngredients.toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: tokens.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      for (final ingredient in detail.activeIngredients)
                        IngredientTag(ingredient: ingredient),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.s6),
                DetailSection(
                  title: l10n.sectionPurpose,
                  icon: LucideIcons.info,
                  paragraphs: detail.purpose,
                  fallbackText: l10n.notProvided,
                ),
                const SizedBox(height: AppSpacing.s6),
                DetailSection(
                  title: l10n.sectionDosage,
                  icon: LucideIcons.clock,
                  paragraphs: detail.dosage,
                  fallbackText: l10n.notProvided,
                ),
                const SizedBox(height: AppSpacing.s6),
                DetailSection(
                  title: l10n.sectionWarnings,
                  icon: LucideIcons.alertTriangle,
                  paragraphs: detail.warnings,
                  fallbackText: l10n.notProvided,
                  isWarning: true,
                ),
                const SizedBox(height: AppSpacing.s6),
                DisclaimerBanner(text: l10n.disclaimer),
              ],
            );
          },
        ),
      ),
    );
  }
}
