# Architecture Decision Record — MedRef

## Context

MedRef is a Flutter app for browsing, searching and saving openFDA drug
labels: a medication list, search, a detail screen and an offline-capable
Favorites tab. This ADR captures the decisions behind the implementation
and the trade-offs that came with them.

## State management: Cubit

**Decision:** `flutter_bloc` Cubits (`MedicationListCubit`, `DetailCubit`,
`FavoritesCubit`, `LocaleCubit`) instead of full Bloc classes or a
non-bloc approach (Provider/Riverpod/setState).

**Why:** Every state transition here is a straightforward "do a thing,
emit a result" — there's no need for the event-sourcing ceremony of
Bloc's event classes when the trigger and the transition are 1:1 (search
changed → debounce → fetch → emit). Cubit keeps the call sites readable
(`cubit.retryFirstLoad()` instead of `add(RetryFirstLoadEvent())`) while
still giving the same testability (`bloc_test`), unidirectional data flow,
and separation from widgets that the take-home asks for.

**Trade-off:** Bloc's event log is useful for replay/debugging complex
interaction sequences (e.g. undo/redo, event sourcing) — Cubit gives that
up. For an app this size that log adds ceremony without a matching
benefit; I'd revisit if the state machine grew branchy interaction chains
(e.g. multi-step forms).

## Project structure: light layering, not a full Clean Architecture

**Decision:** Three visible layers — `data/` (models, repositories, the
openFDA HTTP client), `features/<name>/cubit` + `features/<name>/view`
(business logic and presentation per feature), and `widgets/` (shared,
stateless-where-possible UI). No separate `domain/` layer with UseCase
classes.

**Why:** Repositories return typed models straight into Cubits. Adding a
UseCase layer between them (`GetMedicationsUseCase`) would just forward
the call — pure indirection with the current feature set. The Cubit *is*
the application layer here: it owns orchestration (debounce, pagination,
optimistic updates) and holds no widget/BuildContext references, so the
separation the task cares about — **no business logic inside widgets** —
is intact without the extra layer.

**Trade-off:** if a rule needed to be shared across two different Cubits
unchanged (e.g. "what counts as a valid favorite"), a UseCase would avoid
duplicating it. None of that exists yet at this scope; the ADR's scaling
section below is where that would come back.

## Dependency injection: constructor injection + flutter_bloc's providers

**Decision:** `RepositoryProvider`/`MultiBlocProvider` at the app root
(`app.dart`) wire concrete instances (`MedicationRepository`,
`FavoritesRepository`, Cubits) down the widget tree; every class takes its
dependencies through its constructor (`MedicationRepository({OpenFdaApiClient? client})`,
`FavoritesCubit(FavoritesRepository)`, etc.) rather than reaching for a
service locator.

**Why:** No compile-time codegen (`get_it` + `injectable`) is justified
for ~6 injectable services. Constructor injection means every unit test
in `test/` substitutes a `Mock`/fake with zero DI-framework ceremony —
that mattered more here than the convenience a locator gives a much
larger app.

**Trade-off:** `get_it`/Riverpod would scale better once the object graph
grows past what fits comfortably as constructor parameters, and would
decouple "where a dependency is provided" from "where the widget tree
is" (useful for deep-linking into a feature without mounting its
ancestors). Worth adopting the moment a third or fourth feature needs
the same repository instance from unrelated subtrees.

## Local persistence: SharedPreferences, JSON snapshot

**Decision:** `FavoritesRepository` stores a `List<String>` of JSON-encoded
`MedicationSummary` snapshots (brand/generic/manufacturer/product type,
first active ingredient name, and `set_id`) in `SharedPreferences`, not
the full label.

**Why:** Favorites only need to render `MedicationCard` rows offline —
that's exactly what `MedicationSummary` carries. Storing the full label
(purpose/dosage/warnings, which can be large and multi-valued) would
bloat storage for data the Favorites list never shows; the Detail screen
re-fetches full data by `set_id` when opened, which also means a saved
favorite always shows the *current* label text rather than a possibly
stale copy.

**Trade-off:** opening a favorite while offline can only show the
summary — the Detail screen still needs a network round trip for
Purpose/Dosage/Warnings. A real product would likely cache the full
detail too (e.g. Hive/Drift) once "view saved medication fully offline"
becomes a real requirement; SharedPreferences was sized to what today's
requirement (offline **Favorites list**) actually needs.

## Networking & error handling

**Decision:** `OpenFdaApiClient` maps every outcome to one of four
`FailureKind`s (`network`, `server`, `rateLimit`, `invalidData`) and never
lets `Exception`/`SocketException`/`FormatException` escape to a Cubit or
widget. A 429 is retried in-place with a fixed exponential backoff
(1s → 2s → 4s) before surfacing as `rateLimit`; a 404 is treated as "no
results," not an error, matching openFDA's actual semantics. Widgets map
`Failure` → copy through `presentFailure()` (l10n), never
`exception.toString()`.

**Trade-off:** the backoff schedule is fixed and not configurable via
response headers (openFDA doesn't return `Retry-After`); a production
system talking to an API that does return one would honor it instead of
guessing.

## Testing strategy

**Decision:** three tiers, matching the brief's minimum plus one bonus:

1. **Unit tests** on `OpenFdaApiClient` (mocking `http.Client` with
   `mocktail`) — 200/404/5xx/transport-exception/malformed-body/429-retry
   including a successful recovery mid-backoff — and on
   `MedicationRepository` (mocking the API client) for pagination
   (`hasMore`) and Failure propagation.
2. **Cubit tests** (`bloc_test`) — `MedicationListCubit` covers both
   Loading→Success and Loading→Error on `retryFirstLoad()`, plus the
   "below 2 chars never calls the API" rule; `FavoritesCubit` covers the
   optimistic add, the rollback-on-persistence-failure path, and remove.
3. **Widget smoke test** — confirms the full app (theming, routing,
   localization, DI wiring) boots without throwing.

**Trade-off:** no golden tests were added. The design system's tokens
(colors/spacing/radius) are centralized in `AppTheme`/`AppSpacing`/
`AppRadius` specifically so golden tests would be cheap to add later
(snapshot `MedicationCard`/`DetailSection` in both themes) — cut here for
time, not because it's not worth doing.

## Scaling into a larger hospital app

If this became one feature (Medication Reference) inside a hospital app
with appointments, medical records, labs, prescriptions and
notifications, I'd change:

- **Module boundaries.** Turn each domain (medications, appointments,
  records, labs, prescriptions) into its own package (melos/mono-repo)
  with an explicit public API, so "medications" can't reach into
  "appointments" internals. `core/` (theme, error types, network client
  base) becomes a shared package every feature package depends on.
- **Add a domain layer where rules get shared.** Once two features need
  the same rule (e.g. "is this prescription active" checked from both
  the Prescriptions list and a Medication Detail cross-link), promote it
  out of the Cubit into a UseCase/domain service so it has one owner.
- **DI:** move from constructor-injection-by-hand to `get_it` (or
  Riverpod) registered per module, so feature packages can be composed
  into the app shell (or a differently-flavored app) without every
  screen needing the whole object graph threaded through it.
- **Auth & data sensitivity.** Medical records/lab results are PHI —
  persistence would move from SharedPreferences/plain SQLite to
  encrypted storage, and the network client would gain auth
  (token refresh, certificate pinning) that a public read-only API like
  openFDA never needed.
- **Cross-feature navigation.** `go_router`'s `StatefulShellRoute` per
  tab still works, but tabs become feature-package-owned route
  sub-trees registered into one router, rather than being hardcoded in a
  single `app_router.dart`.
- **Notifications** introduce a cross-cutting concern (a prescription
  refill reminder, a new lab result) that no single feature owns — that
  becomes its own package reacting to domain events (e.g. via a shared
  event bus or backend push), rather than any screen polling for it.
- **Testing** stays the same shape (unit on repositories, Cubit tests on
  state transitions, widget tests on screens) but golden tests become
  mandatory once multiple teams touch shared design-system widgets, to
  catch unintended visual drift across features.
