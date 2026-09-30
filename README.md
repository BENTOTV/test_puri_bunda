# MedRef — Medication Reference

A Flutter app for browsing, searching and saving medication labels from the
public [openFDA Drug Label API](https://open.fda.gov/apis/drug/label/).
Built as a take-home technical exercise — **not medical advice**; every
detail screen says so.

## Flutter version

```
Flutter 3.29.0 • channel [user-branch]
Framework revision 35c388afb5
Engine revision 010c8a806b
Tools • Dart 3.7.0 (DevTools 2.42.0)
```

Check yours with `flutter --version`. This project doesn't pin an SDK via
FVM; any recent 3.29.x / Dart 3.7.x toolchain should work.

## Setup

```bash
flutter pub get
flutter gen-l10n   # regenerates lib/l10n/app_localizations*.dart from the ARB files
```

No API key or `.env` file is required — openFDA's label endpoint is public
and unauthenticated, so the project is runnable without any private
credentials.

## Running the app

```bash
flutter devices          # list available simulators/emulators/browsers
flutter run -d <deviceId>
```

Notes:

- **Web/CORS:** `api.fda.gov` does not send permissive CORS headers, so
  running on Chrome/Edge (`flutter run -d chrome`) will fail to fetch
  data with a browser CORS error. Use an Android emulator, iOS simulator,
  or desktop target instead.
- **Android emulator + Impeller:** on some emulator system images, the
  Vulkan-backed Impeller renderer can hang indefinitely on the native
  splash screen (the app process starts, `Choreographer` logs
  `Skipped N frames`, then nothing — no crash, just no first frame). If
  the app appears stuck on the Flutter logo splash after installing, run:

  ```bash
  flutter run -d <deviceId> --no-enable-impeller
  ```

  This is an emulator/driver limitation, not an app bug — it does not
  reproduce on physical devices or on emulator images with working
  Vulkan/SwiftShader support.

## Running tests

```bash
flutter test
```

This runs:

- `test/data/services/openfda_api_client_test.dart` — HTTP client unit
  tests (success parsing, 404-as-empty, 5xx, transport exceptions,
  malformed bodies, 429 retry/backoff including a mid-backoff recovery).
- `test/data/repositories/medication_repository_test.dart` — pagination
  (`hasMore`) and Failure propagation.
- `test/features/medications/cubit/medication_list_cubit_test.dart` —
  Loading→Success and Loading→Error Cubit transitions, plus the
  below-minimum-length search guard.
- `test/features/favorites/cubit/favorites_cubit_test.dart` — optimistic
  add/remove and rollback-on-persistence-failure.
- `test/widget_test.dart` — a full-app smoke test.

429/rate-limit behavior is simulated entirely with `mocktail` stubs — no
real requests are sent against openFDA during tests.

## Architecture overview

```
lib/
  core/            theme tokens, Failure type + l10n mapper, small utils
  data/
    models/        MedicationSummary, MedicationDetail — defensive JSON parsing
    services/       OpenFdaApiClient (HTTP + retry/backoff + Failure mapping)
    repositories/   MedicationRepository, FavoritesRepository
  features/
    medications/    MedicationListCubit + ListScreen
    detail/         DetailCubit + DetailScreen
    favorites/      FavoritesCubit + FavoritesScreen
    settings/       LocaleCubit (EN/ID switch)
  widgets/          shared, design-system widgets (MedicationCard, StateView, …)
  routing/          go_router StatefulShellRoute (2 tabs) + app shell/tab bar
  l10n/             ARB source + generated AppLocalizations
```

- **State management:** Cubit (`flutter_bloc`) per feature. Business logic
  (debouncing, pagination, retry, optimistic favorite toggling) lives in
  Cubits, not widgets.
- **Dependency injection:** constructor injection everywhere; wired at the
  root in `app.dart` via `RepositoryProvider`/`MultiBlocProvider`. No
  service locator — this keeps every class trivially testable with a
  mock/fake passed straight into its constructor.
- **Error handling:** `OpenFdaApiClient` never lets a raw exception escape
  — everything becomes a `Failure` (`network` / `server` / `rateLimit` /
  `invalidData`), which the UI maps to copy + iconography via
  `presentFailure()`. A 429 is retried with exponential backoff
  (1s → 2s → 4s) before surfacing as a rate-limit state.

See [`docs/ADR.md`](docs/ADR.md) for the reasoning behind these choices,
their trade-offs, and how this would evolve inside a larger hospital app.

## Localization

- English and Bahasa Indonesia via Flutter's ARB-based `gen-l10n`
  (`lib/l10n/app_en.arb`, `lib/l10n/app_id.arb` → generated
  `AppLocalizations`). No user-facing string is hardcoded in a widget.
- The in-app language picker (globe icon on the Medications tab) is
  backed by `LocaleCubit` and switches `MaterialApp.router`'s `locale`
  immediately, independent of the device's system locale.
- **Scope: the app's UI chrome, not the fetched label content.** Switching
  EN/ID re-localizes screen titles, section headers, buttons, hints and
  error copy — everything sourced from our own ARB files. It does not
  translate the medication data itself (brand/generic name, purpose,
  dosage, warnings): that text comes directly from openFDA's Structured
  Product Labeling data, which only exists in English. Auto-translating
  regulated drug label content client-side would be an accuracy/liability
  risk in its own right, so this app deliberately doesn't attempt it.

## Known limitations

- **Medications with no openFDA enrichment are hidden from the browse/
  search list.** A small number of labels come back from openFDA with an
  entirely empty `openfda` object (no brand name, generic name,
  manufacturer, or product type) — a real gap in openFDA's own SPL-to-NDC
  linking, not a parsing bug. There's too little to identify the
  medication by, and showing it as an unlabeled entry read as more
  confusing than useful, so `ListScreen` filters these out rather than
  displaying a name-less card. This is a display-only filter — pagination
  (`skip`/`hasMore` in `MedicationRepository`) still runs against the
  real, unfiltered result count, so it doesn't affect the underlying data.
- **Offline favorites are summary-only.** Favorites persist brand/generic
  /manufacturer/product-type/first-active-ingredient + `set_id` (enough
  for the Favorites list to render offline), not the full label. Opening
  a favorite's detail screen while offline still needs a network round
  trip for Purpose/Dosage/Warnings/active ingredients.
- **No golden tests.** Design tokens are centralized specifically to make
  these cheap to add later, but they weren't included in this submission.
- **Search matches brand/generic name only** (`openfda.brand_name` /
  `openfda.generic_name`, trailing wildcard), not free-text across the
  whole label — a deliberate scope choice for a "reasonable search
  experience," not full-text search.
- **Active ingredient strength parsing is heuristic.** openFDA's
  `active_ingredient` field is free text (e.g. "Ibuprofen 200 mg"); a
  regex splits name from strength and falls back to `openfda.substance_name`
  when the label doesn't provide it structured at all.
- Web is not a supported target for this app (see CORS note above).
- **The language switch doesn't translate API data** — see the scope note
  under Localization above. Only the app's own UI strings are localized;
  medication content stays in English because that's the only language
  openFDA provides it in.

## Approximate time spent

Roughly 16–18 hours end to end: data/error-handling layer and theming
(~4h), screens and shared widgets (~6h), routing/app shell/localization
(~2h), automated tests (~3h), and docs/ADR/README (~1.5h).

## What I'd improve with more time

- Cache the full `MedicationDetail` (not just the summary) for favorited
  items, e.g. via Hive/Drift, so Favorites are genuinely fully offline.
- Golden tests for `MedicationCard`, `DetailSection`, and `StateView` in
  both themes, to lock in the design system visually.
- Widget tests for `ListScreen`/`DetailScreen` interaction flows (search
  debounce, pagination trigger, favorite toggle round-trip).
- Respect a `Retry-After` response header if openFDA ever adds one,
  instead of a fixed backoff schedule.
- Promote shared rules (e.g. "what counts as a valid favorite") into a
  small domain/use-case layer once a second feature needs them — see the
  ADR's scaling section.
#   t e s t _ p u r i _ b u n d a  
 