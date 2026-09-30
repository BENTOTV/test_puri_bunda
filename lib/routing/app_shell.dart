import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/med_ref_colors.dart';
import '../features/favorites/cubit/favorites_cubit.dart';
import '../features/favorites/cubit/favorites_state.dart';
import '../l10n/app_localizations.dart';

/// Bottom navigation with two destinations: Medications and Favorites.
/// A top hairline separates it from content; the Favorites badge shows the
/// saved count in `favorite`.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final tokens = context.medRefColors;
            return NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected:
                  (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
              destinations: [
                NavigationDestination(
                  icon: const Icon(LucideIcons.pill),
                  label: l10n.medicationsTitle,
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: favState.count > 0,
                    label: Text('${favState.count}'),
                    backgroundColor: tokens.favorite,
                    textColor: tokens.onFavorite(),
                    child: const Icon(LucideIcons.heart),
                  ),
                  label: l10n.favoritesTitle,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
