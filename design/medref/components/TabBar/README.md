# TabBar

Bottom navigation with two destinations: Medications and Favorites.

- `surface` with a top hairline, 24px icons + 11px labels; active in `primary`, inactive `ink-subtle`.
- Favorites badge shows the saved count in `favorite`. Each tab keeps its own navigation stack and scroll position (`StatefulShellRoute` in go_router).
