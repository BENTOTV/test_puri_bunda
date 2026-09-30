# SearchField

Search field pinned under the large title on the Medications tab.

- Fill `surface-2`, radius `radius-md`, height `search-h`; focus ring 2px `primary`. Clear button appears when there is text.
- Debounce 400 ms, minimum 2 characters, trims whitespace, cancels in-flight requests (Bloc `restartable()` + `debounce`). Below min length show the hint, don't call the API.
- Clearing returns to the unfiltered list without a new request if it is cached.
