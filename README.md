# HDI Marketing Dashboard

Live display layer for Health Data Innovations' single-source-of-truth marketing dashboard.
Deploys to Netlify (site **hdi-marketing-dashboard**) via continuous deployment — push to
`main` and Netlify builds automatically.

**Editing this repo? Read [`CLAUDE.md`](./CLAUDE.md) first.** It is the standing brief —
load-bearing elements that must not be removed, the data rules, and the per-deploy verify
steps — and it is kept current in the same commit as any code change. This README is the
short orientation; `CLAUDE.md` is the full contract.

## Files (keep this structure — it is load-bearing)
- `CLAUDE.md` — the editing brief. Read before changing anything; keep it current.
- `index.html` — the dashboard (edit this for visuals; vanilla JS + inline CSS, no build step)
- `netlify.toml` + `_redirects` — create the same-origin `/api/*` proxy to the data engine.
  Remove either and the feed 404s ("FEED UNREACHABLE").
- `data/benchmarks.json` — benchmark targets the Benchmarks tab reads

## Data (read-only — never hardcode metrics into index.html)
- `GET /api/snapshots` — current values (HubSpot, GA4, Clarity, LinkedIn)
- `GET /api/snapshots?history=<source>&days=N` — dated history for trend lines.
  Shape: `{ source, days:<int>, rows:[ {date, pulled_at, data:{...}} ] }` — iterate `.rows`,
  read `row.data`, skip `mode:"stub"` rows.
- `GET /data/benchmarks.json` — benchmark config

## Rules that must survive any edit
- No data renders a dash "—", never a zero
- GA4's two most-recent days are `provisional` — label them
- GA4 field names are `sessions`, `engaged`, `key_events` (NOT engagedSessions/keyEvents)
- Clarity is a `metrics{}` object (traffic/scroll_depth/rage_clicks…), not a daily array
- Benchmarks show as "reference until approved"
- Preserve the load-bearing UI: the date-range controls (`rangeSeg`, `drFrom`, `drTo`,
  `drApply`, `rangeNow` + the `fetchHist`/`applyWindow` wiring) and the Traffic-quality
  (bot) panel on the Website tab. Restyling is fine; rewiring is not. See `CLAUDE.md`.

## Editing
Read `CLAUDE.md`, then: `git pull` → branch → edit `index.html` (and `CLAUDE.md` if the
change is load-bearing) → push the branch → open a PR → review Netlify's Deploy Preview →
merge to `main` to go live. Commit straight to `main` only for trivial colour/spacing tweaks.
