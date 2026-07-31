# Handyman jobs app

A job management app for a solo handyman business. Two standalone HTML files,
no build step, no framework, no package manager.

## Files

- `handyman-jobs.html` — the phone app. Everything lives in this one file.
- `handyman-office.html` — desktop job intake for office staff. Produces a
  `.json` file or a `HJ1:` base64 code that the phone imports.

Open either directly in a browser. There is nothing to compile.

## Hard constraints — do not break these

- **Single file per app.** All CSS and JS inline. No bundler, no imports.
- **No webfonts.** System font stack only (`--sans`, `--mono`). Webfonts were
  removed deliberately: the owner's environment blocks outbound requests, so
  they never loaded, and everything silently fell back to system type anyway.
- **No `localStorage`.** Storage goes through the `store` shim, which uses
  `window.storage` when present and falls back to an in-memory object.
- **No native dialogs.** `confirm()`, `alert()` and `prompt()` are silently
  suppressed in sandboxed frames — a delete button once did nothing because of
  this. Use the in-app `ask(title, body, yesLabel, danger)` promise instead.
- **No `window.open()`.** Popup blockers swallow it without error. Use a real
  `<a href target="_blank">` and update its `href` (see `syncRoute()`).
- **Assume the network may be unavailable.** Every outbound call needs a
  visible fallback. The map falls back to a self-drawn SVG plan view; address
  lookup falls back to pasting coordinates.

## Design language

Minimal: contrast and whitespace do the work, not borders and shadows.

- **Black is the action colour, amber is the attention colour.** Primary
  buttons are solid ink. `--accent` amber appears only in small status marks
  (the progress rail, a running timer, the live dot). Never as a large fill.
- **Monospace means machine data** — job numbers, dates, coordinates,
  distances, money. Sans is for human words. This rule is consistent
  throughout; keep it.
- Large titles use tight negative letterspacing (-.02em to -.03em).
- Signature element: the **five-segment progress rail** on each job row.
  Stages behind you in ink, current stage in amber (green when finished),
  the rest faint. It replaced a bordered status badge.
- All colour goes through CSS custom properties. Both light and dark palettes
  are defined; dark is duplicated under `:root[data-theme="dark"]` and inside
  `@media (prefers-color-scheme:dark)`. **Adding a token means adding it to
  all three blocks.** There's no literal hex in any rule except deliberate
  over-photo scrims and shadows.

## Data model

Jobs live in one array under the `hj:jobs` key. Photos are stored separately
per job under `hj:photos:<id>` so the index stays light. Settings under
`hj:settings`.

```
job = {
  id, num, created, src?,        // src = id assigned by the office page
  title, customer, phone, email, address, quote, rate?,
  status,                        // quoted | booked | progress | done | invoiced
  lat?, lng?, acc?, fromAddress?,
  photoCount,
  sessions: [{s, e?}],           // absolute ms timestamps; no `e` means running
  parts:    [{n, q, c}],
  log:      [{t, x, s}]          // s = shared with customer in the email
}
```

Timers store absolute timestamps rather than counters, so they stay correct
when the app is closed or the phone sleeps. Only one timer runs at a time —
starting one stops any other.

Notes default to private. Only `s: true` notes go into the customer email.
Older jobs had a single `notes` string; `migrateNotes()` folds it into `log`
on boot and is idempotent.

## Working on this

- Verify with `node --check` on the extracted script block before shipping.
  A quick harness that pulls pure functions out and tests the maths
  (durations, rounding, cost, coordinate parsing) has caught real bugs.
- Check every `$('id')` resolves to an element that exists.
- Check no CSS rule reintroduces a literal colour.

## State of play

Done: jobs list, photos via camera, email handoff, Google Maps directions,
GPS pins, OpenStreetMap map with plan-view fallback, route planner, dark
mode, per-job timer with hourly-rate costing, parts and materials with
totals against the quote, notes log, office intake page, JSON backup and
restore, hosting over https (GitHub Pages).

Live at:
- https://csw007.github.io/handyman-jobs-app/handyman-jobs.html (phone app)
- https://csw007.github.io/handyman-jobs-app/handyman-office.html (office intake)

Not done, roughly in priority order:

1. **Supabase sync** so office staff and the phone share one database.
   Planned shape: `jobs` table with `id text primary key`, `data jsonb`,
   `deleted boolean`, `updated_at timestamptz`; RLS allowing any
   authenticated user. Offline-first — local stays the source of truth, sync
   pushes and pulls on a debounce, last-write-wins on `updated_at`. Deletes
   via a local tombstone list rather than soft-deleting in the jobs array, so
   the render paths don't all need filtering. Photos stay local; they'd
   swamp the free tier.
2. **Invoicing** — a real invoice document rather than a plain-text email.
   GST is not handled anywhere yet and matters if the owner is registered.
3. Google Maps embed key (optional; the OpenStreetMap view already works).

## Deploying

Hosted on GitHub Pages, serving straight off the `main` branch — no build
step. Any push to `main` goes live within about a minute.

Easiest path: run `deploy.ps1` in this folder (PowerShell). It stages
everything, asks for a one-line description, commits, and pushes.

Manual equivalent:
```
git add -A
git commit -m "describe the change"
git push
```

## About the owner

Runs the business solo, uses this on a phone, on site, one-handed, often
outdoors and sometimes with no signal. Not a developer. Explain tradeoffs
in plain terms and say plainly when something can't work rather than
building around it quietly.
