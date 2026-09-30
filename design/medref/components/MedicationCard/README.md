# MedicationCard

List row for one label: brand name, generic name, manufacturer, product-type badge and the favorite toggle.

- Brand `headline` (1 line, ellipsis); generic `subhead` `ink-muted` (2 lines); manufacturer `footnote` `ink-muted` (1 line).
- Missing values: brand → generic name promoted, else "Brand name unavailable"; manufacturer → italic "Unknown manufacturer". Multiple values → first + "· +N more".
- OTC / Rx badge from `openfda.product_type`; hide when absent.
- Whole card taps to detail; semantics label reads "brand, generic, manufacturer". Takes a presentation model (`MedicationSummary`), never raw JSON.
