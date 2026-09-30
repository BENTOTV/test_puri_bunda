# DetailSection

Card for one label field on the detail screen (Purpose, Dosage, Warnings, …).

- `radius-lg`, `surface`; header = 20px icon + uppercase `caption` label; body `body` 17/24.
- Long text clamps at 6 lines with Show more / Show less (`AnimatedSize`). Label arrays joined with paragraph breaks; leading section words ("Warnings:") stripped.
- Warnings variant tints the header `warning-soft`. Missing field: show "Not provided in this label." or hide the section — pick one rule and apply it everywhere (recommended: hide optional, show fallback for Purpose/Dosage/Warnings).
