# FavoriteButton

Heart toggle that saves or removes a medication from Favorites.

- 44×44 hit area (`tap-min`), 24px icon. Off: outline in `ink-subtle`. On: filled in `favorite`.
- Toggle is optimistic: update UI immediately via `FavoritesCubit`, persist, roll back on failure. Removing from the Favorites tab shows a snackbar with Undo.
- Semantics: `Semantics(toggled: isFavorite, label: l10n.addFavorite / removeFavorite)`. Never color-only: the fill changes too.
