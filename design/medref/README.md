# MedRef

A calm, clinical design system for the **Medication Reference** Flutter app (take-home test): browse, search and save openFDA drug labels. Built on Apple HIG patterns — large titles, grouped surfaces, 44pt targets — with one brand teal and one favorite orange.

> MedRef is an original, neutral identity for a technical exercise. It carries no hospital logo or trademark; there is no logo, so the name is set in plain type.

## Principles

1. **Reference, not advice.** Every detail screen ends with the *For reference only* note (`primary-soft`). Warnings get their own tinted section (`warning-soft`) but never alarm colors in the list.
2. **Label data is messy — design for it.** Every field can be missing or have many values. Missing → a quiet italic fallback in `ink-muted` ("Unknown manufacturer", "Not provided in this label"). Many → show the first, then "· +N more".
3. **One thing is loud per screen.** Brand name (`headline` / `title-1`) leads; generic and manufacturer step down to `ink-muted`. Teal marks what you can tap; orange only means *saved*.
4. **Always tell the user what's happening.** Skeletons on first load, a footer spinner for load-more, a state view for empty / error / rate-limit, each with one action.

## Voice & copy

Short, plain, second person, no blame, no exclamation marks. Errors say what happened and what to do. All strings live in ARB files (`lib/l10n/app_en.arb`, `app_id.arb`), never in widgets.

| key | English | Bahasa Indonesia |
| --- | --- | --- |
| `medicationsTitle` | Medications | Obat |
| `favoritesTitle` | Favorites | Favorit |
| `searchHint` | Search brand or generic name | Cari nama merek atau generik |
| `searchMinChars` | Type at least 2 characters to search | Ketik minimal 2 karakter untuk mencari |
| `unknownManufacturer` | Unknown manufacturer | Produsen tidak diketahui |
| `brandUnavailable` | Brand name unavailable | Nama merek tidak tersedia |
| `moreValues` | +{count} more | +{count} lainnya |
| `sectionPurpose` / `Dosage` / `Warnings` / `ActiveIngredients` | Purpose · Dosage · Warnings · Active ingredients | Kegunaan · Dosis · Peringatan · Bahan aktif |
| `notProvided` | Not provided in this label. | Tidak tercantum pada label ini. |
| `showMore` / `showLess` | Show more / Show less | Tampilkan lebih banyak / Tampilkan lebih sedikit |
| `emptySearchTitle` | No medications found | Obat tidak ditemukan |
| `emptySearchBody` | Nothing matches “{query}”. Check the spelling or try a generic name. | Tidak ada yang cocok dengan “{query}”. Periksa ejaan atau coba nama generik. |
| `errorNetworkTitle` | Can’t connect | Tidak dapat terhubung |
| `errorNetworkBody` | Check your internet connection and try again. | Periksa koneksi internet Anda lalu coba lagi. |
| `errorServerTitle` | Something went wrong | Terjadi kesalahan |
| `errorRateLimitTitle` | Too many requests | Terlalu banyak permintaan |
| `errorRateLimitBody` | openFDA is limiting requests right now. Please wait a moment. | openFDA sedang membatasi permintaan. Mohon tunggu sebentar. |
| `retry` | Try again | Coba lagi |
| `favoritesEmptyTitle` | No favorites yet | Belum ada favorit |
| `favoritesEmptyBody` | Tap the heart on any medication to keep it here, even offline. | Ketuk ikon hati pada obat mana pun untuk menyimpannya di sini, bahkan saat offline. |
| `addFavorite` / `removeFavorite` | Add to favorites / Remove from favorites | Tambah ke favorit / Hapus dari favorit |
| `removedSnack` | Removed from favorites | Dihapus dari favorit |
| `undo` | Undo | Urungkan |
| `disclaimer` | For reference only. Data comes from the public openFDA label database and is not medical advice. | Hanya untuk referensi. Data berasal dari basis data label openFDA publik dan bukan saran medis. |

## Visual foundations

- **Color.** Neutral-first. `bg` behind everything, content on `surface` cards, inputs and skeletons on `surface-2`. `primary` teal for interaction; `favorite` orange only for the saved heart and the Favorites badge; `danger` and `warning` only inside state views, banners and the Warnings section. Every text pair is ≥4.5:1 in light **and** dark; `ink-subtle` is for icons only (≥3:1).
- **Type.** Inter (system SF/Roboto fallback), HIG sizes: `large-title` 34 for tab titles, `title-1` 28 for the detail brand name, `headline` 17/600 for list brand names, `subhead` 15 for generic names, `footnote` 13 for manufacturer, `caption` 12 uppercase for section labels. Support Dynamic Type / `textScaler` up to 200% — rows grow, never clip.
- **Spacing.** 4-pt grid: `space-4` (16) screen gutters and card padding, `space-3` (12) between cards, `space-6` (24) between detail sections.
- **Shape.** `radius-md` 12 for cards, buttons, search; `radius-lg` 16 for detail sections; `radius-sm` 8 for tags and banners. Light mode uses `shadow-card`; dark mode separates by surface lightness, no shadow.
- **Motion.** 200 ms ease-out for expand/collapse and favorite toggle. Spinner stops under reduced motion.

## Iconography

Line icons, 1.8 stroke, round caps, 24px (`icon-md`) or 20px (`icon-sm`), drawn in `currentColor`. In Flutter use **Cupertino Icons** or **Lucide** (`lucide_icons`) for the same look: `search`, `heart` (outline / filled), `pill`, `chevron-right`, `wifi-off`, `clock`, `alert-triangle`, `info`, `globe`. The filled heart is the only filled icon.

## Behaviour the design assumes

- **Search:** debounce 400 ms, min 2 chars, cancel stale requests (`restartable()` transformer in the Bloc). Query `openfda.brand_name` OR `openfda.generic_name` with a trailing wildcard. A 404 from openFDA means "no results" → empty state, not error.
- **List:** `limit=20`, `skip` for load more, triggered 300px before the end; footer spinner; pull-to-refresh keeps the current list visible.
- **Errors:** map to 4 failures — network, server (5xx), rate-limit (429, retry with exponential backoff 1s→2s→4s, then show the state), invalid data. Errors during load-more show an inline banner + retry, not a full-screen state.
- **Favorites:** stored locally (Hive / SharedPreferences / Drift) as a snapshot of the card fields plus `set_id`, so the Favorites tab works offline.

## Flutter mapping

Tokens become one `ThemeData` per brightness plus a `ThemeExtension<MedRefColors>` for the tokens Material has no slot for (`favorite`, `warning`, `warning-soft`, `ink-muted`, `ink-subtle`).

| token | Flutter |
| --- | --- |
| `primary` / `on-primary` | `ColorScheme.primary` / `onPrimary` |
| `primary-soft` / `on-primary-soft` | `primaryContainer` / `onPrimaryContainer` |
| `surface`, `surface-2`, `bg` | `surface`, `surfaceContainerHighest`, `scaffoldBackgroundColor` |
| `ink`, `separator` | `onSurface`, `outlineVariant` |
| `danger` / `danger-soft` | `error` / `errorContainer` |
| type styles | `TextTheme`: displaySmall=`large-title`, headlineMedium=`title-1`, titleLarge=`title-3`, titleMedium=`headline`, bodyLarge=`body`, bodyMedium=`subhead`, bodySmall=`footnote`, labelSmall=`caption` |
| spacing / radius | `abstract final class AppSpacing { static const s4 = 16.0; … }`, `AppRadius.md = 12.0` |

Widgets read tokens only through `Theme.of(context)` and `context.medRefColors` — never hex literals — so golden tests can snapshot both themes from the same widget.
