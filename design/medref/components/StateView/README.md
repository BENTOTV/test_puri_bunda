# StateView

Full-area feedback for loading, empty, error and rate-limited states.

- Loading: 6 skeleton cards (first load), footer spinner (load more). Never a blank screen.
- Empty / error / 429: 56px icon disc, `title-3` title, `subhead` message, one button. Error copy comes from a `Failure` → l10n mapper, never `exception.toString()`.
- Error disc uses `danger-soft`, rate-limit uses `warning-soft`, empty uses `surface-2`. Announce with `Semantics(liveRegion: true)`.
