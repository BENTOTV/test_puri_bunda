# Button

Buttons trigger one action: `primary` for the single main action of a state (Try again), `secondary` for a recovery or alternative (Clear search, Browse medications), `text` for inline actions (Show more).

- Height `button-h` (50), radius `radius-md`, label `button` style. Full width inside state views on narrow screens.
- One primary per screen state. Disabled = 40% opacity, still announced.
- Flutter: `FilledButton` / `FilledButton.tonal` / `TextButton` themed from tokens; label from ARB.
