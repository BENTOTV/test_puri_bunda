import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/med_ref_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/medication_card.dart';
import '../../../widgets/state_view.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

/// Saved list — works fully offline. Rows reuse [MedicationCard]; swipe to
/// remove with Undo; tapping opens detail from the saved snapshot,
/// refreshing from the API when online.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                l10n.favoritesTitle,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state.list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: StateView(
                      icon: LucideIcons.heart,
                      discColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      iconColor: context.medRefColors.inkSubtle,
                      title: l10n.favoritesEmptyTitle,
                      message: l10n.favoritesEmptyBody,
                    ),
                  );
                }

                final items = state.list;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s4,
                    0,
                    AppSpacing.s4,
                    AppSpacing.s8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final summary = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                        child: Dismissible(
                          key: ValueKey(summary.setId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              borderRadius: AppRadius.mdRadius,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s4,
                            ),
                            child: Icon(
                              LucideIcons.trash2,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          onDismissed: (_) {
                            context.read<FavoritesCubit>().remove(
                              summary.setId,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.removedSnack),
                                action: SnackBarAction(
                                  label: l10n.undo,
                                  onPressed:
                                      () => context
                                          .read<FavoritesCubit>()
                                          .toggle(summary),
                                ),
                              ),
                            );
                          },
                          child: MedicationCard(
                            summary: summary,
                            isFavorite: true,
                            onTap:
                                () => context.push(
                                  '/medication/${summary.setId}',
                                  extra: summary,
                                ),
                            onFavoriteToggle:
                                () => context.read<FavoritesCubit>().remove(
                                  summary.setId,
                                ),
                          ),
                        ),
                      );
                    }, childCount: items.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
