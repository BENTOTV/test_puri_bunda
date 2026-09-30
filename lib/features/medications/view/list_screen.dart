import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/failure_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/med_ref_colors.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/disclaimer_banner.dart';
import '../../../widgets/language_sheet.dart';
import '../../../widgets/medication_card.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/skeleton_card_list.dart';
import '../../../widgets/state_view.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../../favorites/cubit/favorites_state.dart';
import '../cubit/medication_list_cubit.dart';
import '../cubit/medication_list_state.dart';

const _loadMoreTriggerOffset = 300.0;

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late final MedicationListCubit _cubit;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = MedicationListCubit(context.read<MedicationRepository>())
      ..retryFirstLoad();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreTriggerOffset) {
      _cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator.adaptive(
            onRefresh: _cubit.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Text(
                    l10n.medicationsTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(LucideIcons.globe),
                      tooltip: l10n.language,
                      onPressed: () => showLanguageSheet(context),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s4,
                    0,
                    AppSpacing.s4,
                    AppSpacing.s3,
                  ),
                  sliver: SliverToBoxAdapter(
                    child:
                        BlocBuilder<MedicationListCubit, MedicationListState>(
                          buildWhen: (a, b) => a.query != b.query,
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SearchField(
                                  controller: _searchController,
                                  hintText: l10n.searchHint,
                                  onChanged: _cubit.onSearchChanged,
                                ),
                                if (state.belowMinQueryLength)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.s2,
                                    ),
                                    child: Text(
                                      l10n.searchMinChars,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: context.medRefColors.inkMuted,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                  ),
                ),
                BlocBuilder<MedicationListCubit, MedicationListState>(
                  builder: (context, state) {
                    if (state.isLoading && state.items.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: SkeletonCardList(),
                      );
                    }

                    if (state.firstLoadFailure != null) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: StateView.failure(
                          context,
                          presentation: presentFailure(
                            state.firstLoadFailure!,
                            l10n,
                          ),
                          buttonLabel: l10n.retry,
                          onButtonPressed: _cubit.retryFirstLoad,
                        ),
                      );
                    }

                    if (state.isEmptyResult) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: StateView(
                          icon: LucideIcons.pill,
                          discColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          iconColor: context.medRefColors.inkSubtle,
                          title: l10n.emptySearchTitle,
                          message: l10n.emptySearchBody(state.query),
                          buttonLabel:
                              state.query.isNotEmpty ? l10n.clearSearch : null,
                          onButtonPressed:
                              state.query.isNotEmpty
                                  ? () {
                                    _searchController.clear();
                                    _cubit.onSearchChanged('');
                                  }
                                  : null,
                        ),
                      );
                    }

                    // Labels openFDA never enriched (empty brand/generic/
                    // manufacturer/product type) carry too little to
                    // identify by, so they're filtered out of the browse
                    // list here — the Cubit's own pagination bookkeeping
                    // (skip/hasMore) stays based on the raw, unfiltered
                    // fetch and is unaffected.
                    final visibleItems =
                        state.items.where((s) => s.hasOpenfdaData).toList();

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s4,
                        0,
                        AppSpacing.s4,
                        AppSpacing.s8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index == visibleItems.length) {
                            if (state.loadMoreFailure != null) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.s3,
                                ),
                                child: Column(
                                  children: [
                                    DisclaimerBanner(
                                      text:
                                          presentFailure(
                                            state.loadMoreFailure!,
                                            l10n,
                                          ).message,
                                      variant:
                                          state.loadMoreFailure!.kind ==
                                                  FailureKind.rateLimit
                                              ? DisclaimerVariant.warn
                                              : DisclaimerVariant.err,
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                    AppButton(
                                      label: l10n.retry,
                                      variant: AppButtonVariant.text,
                                      onPressed: _cubit.retryLoadMore,
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (state.isLoadingMore) {
                              return const LoadMoreFooter();
                            }
                            return const SizedBox.shrink();
                          }

                          final summary = visibleItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.s3,
                            ),
                            child: BlocBuilder<FavoritesCubit, FavoritesState>(
                              buildWhen:
                                  (a, b) =>
                                      a.isFavorite(summary.setId) !=
                                      b.isFavorite(summary.setId),
                              builder: (context, favState) {
                                return MedicationCard(
                                  summary: summary,
                                  isFavorite: favState.isFavorite(
                                    summary.setId,
                                  ),
                                  onTap:
                                      () => context.push(
                                        '/medication/${summary.setId}',
                                        extra: summary,
                                      ),
                                  onFavoriteToggle:
                                      () => context
                                          .read<FavoritesCubit>()
                                          .toggle(summary),
                                );
                              },
                            ),
                          );
                        }, childCount: visibleItems.length + 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
