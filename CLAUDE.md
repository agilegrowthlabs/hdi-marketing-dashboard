# CLAUDE.md — HDI Marketing Dashboard (project memory)

This file is the standing brief for anyone — human or AI — editing this repo. It is read
at the start of a session and travels with every `git pull`, so it is always current: you
do NOT need to be handed a separate note. Read it fully before making changes.

YOUR JOB: visual / layout changes to `index.html` ONLY. Never touch the data pipeline, and
never remove a load-bearing element listed under "DO NOT REMOVE" below.

## KEEP THIS FILE CURRENT (important)
If you add, move, or change any load-bearing element — a control, a panel, a data rule, a
verify step — update THIS file in the SAME commit as the code change. That is what keeps
the next session accurate with zero re-briefing. A code change that alters behaviour but
leaves CLAUDE.md stale is an incomplete change. When you add a "DO NOT REMOVE" element,
add a matching block here; when you change the data shape a panel depends on, update its
rule and its verify step.

Last substantive update: 2026-08-14 — date-range controls, Traffic-quality (bot) panel,
Insights tab + Clarity bot-filter toggle.

## STATUS — READ THIS FIRST
- Live at https://hdi-marketing-dashboard.netlify.app and the code on `main` matches it
  exactly. Always `git pull` and build on the CURRENT `main`. Do NOT resurrect an older
  local copy — an old copy is missing recent features and pushing it would delete them.
- The current `index.html` on `main` is the canonical base. It has been verified against
  the LIVE feed: 0 JS errors, Clarity/GA4/HubSpot render real numbers, channels are
  inflation-safe (deduped per date), nothing hardcoded, and the 7/30/90/All + custom
  date-range controls all filter real data correctly.
- The repo is clean: index.html, netlify.toml, _redirects, data/benchmarks.json,
  README.md, CLAUDE.md. No stray copies or scratch files.

## PIPELINE
Repo: https://github.com/agilegrowthlabs/hdi-marketing-dashboard  (public)
Push to `main` -> Netlify auto-builds -> https://hdi-marketing-dashboard.netlify.app
No manual deploys, no deploy tokens (Netlify's GitHub app publishes).

## SETUP
The push credential is provided to your session separately and is NEVER stored in this
repo. Never commit, echo, or print it. Keep it out of clone history:

    git clone https://github.com/agilegrowthlabs/hdi-marketing-dashboard.git
    cd hdi-marketing-dashboard
    git remote set-url origin https://<PUSH_TOKEN>@github.com/agilegrowthlabs/hdi-marketing-dashboard.git
    # when done pushing, strip the token back out:
    #   git remote set-url origin https://github.com/agilegrowthlabs/hdi-marketing-dashboard.git

## HOW TO MAKE A VISUAL CHANGE (every edit)
    git pull                       # ALWAYS start from the latest main
    git checkout -b describe-the-change
    # edit index.html only (and CLAUDE.md if the change is load-bearing)
    git add index.html CLAUDE.md && git commit -m "what changed"
    git push -u origin describe-the-change
Open a PR -> Netlify posts a Deploy Preview URL -> review it against the reference image
-> merge to `main` to go live. (Or commit straight to `main` for an immediate production
deploy once you're confident.)

## WHEN HENRY SENDS A REFERENCE IMAGE
Match its layout, hierarchy, and chart style. Keep the design system:
- Colors: teal `#0F5C56`, lime `#C3D82B`, sage `#8ECAC4`, taupe `#A89C8E`
- Fonts: Archivo (display) + IBM Plex Mono (labels/numbers)
Work in index.html's inline CSS + the render functions; it is vanilla JS, no build step.

## DO NOT REMOVE — THE DATE-RANGE FEATURE (load-bearing)
The header has a time-range control that scopes the whole dashboard to any window.
Preserve ALL of the following. If a redesign moves these, keep the same element IDs and
the same JS wiring — every tab depends on them.

HTML (in the header `.hd` bar):
- `<span class="seg" id="rangeSeg">` with preset buttons `data-d="7"`, `"30"`, `"90"`, `"0"` (=All).
- `<span class="dr">` containing `<input type="date" id="drFrom">`, `<input type="date" id="drTo">`, `<button id="drApply">`.
- `<span class="rangeNow" id="rangeNow">` — the "Showing <start> – <end>" readout.

JS (all in the inline `<script>`):
- Globals: `RAW{}`, `WIN{start,end}`, `MODE` ("preset"|"custom"), `LASTPRESET`, `WIDE`, `DAYS`.
- `fetchHist()` fetches the FULL history once (`days=WIDE`) and caches it in `RAW` — it does
  NOT refetch per range. Do not change it back to fetching `days=DAYS`.
- `applyWindow()` filters each source's `RAW` rows to `WIN` [start,end], then runs the
  existing `normHist()`/`aggGA4()` on the trimmed set and calls `render()`. This makes the
  ranges real. Keep it.
- `setPreset()`, `syncControls()`, `validateApply()`, `inWin()`, `earliestISO()`, and the
  date helpers (`isoDay`/`todayISO`/`shiftISO`/`daysInclusive`/`fmtDay`) support it.
- Labels are span-aware: `hsRange()` `out.label` and `deltaTxt()` read `MODE`/`WIN`. Keep.

One line: the page holds all history in the browser and re-windows it on the client, so
presets AND custom From/To dates both show correct, different numbers with no extra server
calls. Restyle the controls freely — just don't delete the IDs above or rewire fetch/filter.

## DO NOT REMOVE — THE TRAFFIC-QUALITY (BOT) PANEL (load-bearing)
The Website tab has a "Traffic quality · Clarity" card ABOVE the "Behaviour · Clarity"
card. It surfaces the human-vs-bot split otherwise buried in the Clarity payload (a large
share of Clarity sessions are automated). Preserve it. Restyle freely, but keep:
- `clarityTraffic(c)` — reads `metrics.traffic.totalSessionCount` (human) and
  `.totalBotSessionCount` (bot), plus the "Traffic" slice of `dimensions.channel_country`
  and `dimensions.os_browser_device` for the concentration + device-fingerprint callouts.
  Returns null unless BOTH counts are numeric, so older snapshots simply skip the card.
- The render block in `website()` that draws HUMAN / BOT / BOT SHARE KPIs, the human-vs-bot
  split bar, and the two foot notes.

Rules specific to this panel:
- Headline totals come from `metrics.traffic` (authoritative). The per-bucket dimension
  slice can sum slightly differently — a known Clarity quirk; do not "reconcile" them by
  summing the dimension rows into the headline.
- This is a CURRENT-SNAPSHOT view of Clarity's own tracked window (`window_days`), NOT the
  7/30/90 date range. Don't wire it to `WIN`/`DAYS` — label it by `window_days`.
- Keep it Clarity-scoped and separate from GA4. GA4 applies its own server-side bot
  filtering, so never imply the GA4 Sessions number carries this bot share.
- Never hardcode the counts. If Clarity returns no bot field, the card must disappear, not
  show a stale/zero number.

## DO NOT REMOVE — THE INSIGHTS TAB + BOT-FILTER TOGGLE (load-bearing)
Second tab, "Insights" (`data-t="ins"`, pane `#p-ins`), rendered by `insights()`. It is the
interpretation layer, modelled on Henry's reference images (comparison → trend → benchmark
position → takeaway). In order: a narrative headline + all-GA4 comparison KPI cards (each shows
current, the ↑/↓ vs the prior 30 days, and the prior baseline); a Traffic-trend chart with a
dashed regression trend line; an "HDI vs industry benchmark" table that labels each metric
AHEAD / IN LINE / BEHIND; an "Engagement by channel" bar chart (the lever — bars coloured by
whether they clear the benchmark, tick = benchmark, n = sessions); an engagement-vs-benchmark
trend chart; a "Correlation & causation" card (states the correlation, then explicitly what we
can't claim as causal); a "How to read GA4 vs Clarity" context box; the Clarity human-vs-bot
stored-history table; a green "What leadership should take away" box; and a "Not yet measured"
roadmap note. Nothing from Clarity sits on the GA4 strip, so the two never appear to contradict.
The tab is DRIVEN BY THE DATE FILTER: `ga4Window()` scopes GA4 to the selected range `WIN` and
compares it to the equal-length window immediately before it (so "vs prior N days" is like-for-
like, and the labels say the actual N — never quarterly). A comparison only shows when the prior
window has comparable data coverage, else it reads "no prior period in range" (prevents the
divide-by-near-zero +thousands% you get when a window reaches before our May-15 data start).
Preserve it. Restyle freely, but keep:
- Shared helpers `ga4Window()` (windowed current/prior sums) and `ga4Channels(curDates)` (engaged
  rate + sessions per channel) — used by BOTH Insights and the Website tab so they compute
  identically. `benchPos()` returns the AHEAD/IN LINE/BEHIND label. Don't fork these per-tab.
- `trend(series, opts)` supports `opts.trendline` (dashed regression) and `opts.benchmark`
  (dashed reference line) — the Insights charts use both. Don't remove them.
- Website tab GA4 section uses the same `ga4Window()`/`ga4Channels()`: Sessions/Visitors show the
  period comparison, Engagement rate shows its benchmark position, and "Channels — what's driving
  results" shows engaged rate + each channel's share of sessions. It does NOT show KEY EVENTS or
  VISITOR TO LEAD (not collected yet). Keep those off both tabs until the data exists.
- `insights()` and the stat helpers `_sum`/`_mean`/`pearson`/`slopePerDay`/`growthPct`/`pctTxt`,
  and the `IB` researched-benchmark constants (each shown with its source in-UI).
- The header toggle `#botTog` (INCLBOTS) and its handler.
Rules specific to these:
- `insights()` computes over the FULL stored GA4 history (`normHist({rows:RAW.ga4.rows},"ga4")`),
  deliberately independent of the top date range — it is an over-time interpretation, not a
  windowed view. Don't wire it to WIN/DAYS.
- Every figure is computed live from the series with sample size (n) shown. Never hardcode a
  verdict or a stat. Benchmarks in `IB` are external references (cited), not approved targets.
- Correlation is labelled "not causation" and must stay that way. Do not relabel an observed
  correlation as causal — the data is observational.
- The bot filter (`INCLBOTS`, default false = human-only) governs CLARITY session figures only
  (Behaviour panel "Sessions", Traffic-quality filter line). It must NOT be applied to GA4
  numbers — Clarity's per-session bot detection does not map onto GA4 sessions, and GA4 filters
  bots server-side already. Keep the filter Clarity-scoped.
- The Clarity human-vs-bot history cannot be backfilled (Clarity's API only serves 72h); it
  grows forward one stored day at a time. Don't add a "backfill Clarity" path — there's no
  source for it.

## DATA / EDIT RULES (load-bearing — do not break)
- Edit ONLY `index.html`. Keep `netlify.toml` + `_redirects` at the repo ROOT and
  `data/benchmarks.json` inside `data/`. Removing any 404s the `/api` proxy ("FEED UNREACHABLE").
- The dashboard reads data live and read-only:
    - `GET /api/snapshots` — current values, all sources
    - `GET /api/snapshots?history=<source>&days=N` — dated history; source =
      hubspot|ga4|clarity|linkedin. Shape: `{ source, days:<int>, rows:[ {date, pulled_at,
      data:{...}} ] }` — iterate `.rows`, read `row.data`, skip rows where `data.mode === "stub"`.
    - `GET /data/benchmarks.json` — benchmark targets
- Never hardcode a metric. No data renders a dash "—", never a zero.
- GA4's two most-recent days are provisional — label them, don't present as final.
- Live-path GA4 fields: `sessions`, `engaged`, `key_events` (NOT engagedSessions/keyEvents).
- Clarity is a `metrics{}` OBJECT with nested sub-objects (`traffic.totalSessionCount`,
  `scroll_depth.averageScrollDepth`, `rage_clicks.sessionsWithMetricPercentage`, ...) and
  some values arrive as strings. index.html normalises this via `claritySize()`; reuse it —
  don't read `cm.scroll_depth` etc. as flat numbers.
- GA4 `days` and `channels` BOTH carry a `date` and recur across snapshots — dedupe per date
  (settled over provisional) THEN sum. `aggGA4()` already does this; don't sum raw.
- `top_pages` has NO date — snapshot-level rollup. Latest snapshot only; never sum.
- HubSpot cumulative metrics (won/lost) are latest−earliest across the window, never summed —
  `hsRange()` enforces this. Closed Won must never exceed **$1,178,260** (the exact all-time
  figure). Use the exact number, not "~$1.18M": a summing bug across the 16 snapshots yields
  roughly $18M (obvious), but a subtler row-ordering bug can yield something like $1.4M — an
  approximate check would wave that through, an exact one won't.
- Cumulative in-window deltas can only be >= 0 (a running total can't go down). If the
  won/lost/n_won/n_lost delta comes out NEGATIVE, the snapshot rows are out of order or the
  feed reset — the figure is not trustworthy. `hsRange()` detects this (its `negative` check),
  sets `suspect=true`, and falls back to the all-time figure WITH a note rather than printing
  negative revenue. Keep that fallback; a redesign must not strip it.
- History depth: GA4 goes back to ~May 15; HubSpot/Clarity only to ~Jul 29. Custom windows
  earlier than a source's history correctly show dashes for that source.
- Benchmarks show as "reference until approved" (approved = `hdi_target != null`).

## VERIFY EVERY DEPLOY (before calling it done)
    curl -s -o /dev/null -w "snapshots %{http_code}\n" https://hdi-marketing-dashboard.netlify.app/api/snapshots
Must be 200. Then open `https://hdi-marketing-dashboard.netlify.app/?v=NNN` and confirm:
- GA4 + Clarity + HubSpot panels show live numbers; no "FEED UNREACHABLE" banner.
- The 7D/30D/90D/All buttons change the numbers (e.g. Website Sessions: 7D ≈ a few hundred,
  90D ≈ a few thousand — they must differ).
- ACTUALLY EXERCISE THE CUSTOM PICKER — a working preset button does NOT prove it. Type a
  From and a To date (e.g. a single mid-month window), click Apply, and confirm the numbers
  change to match those exact dates and the "Showing …" pill updates. Then set To earlier
  than From and confirm Apply stays DISABLED. `validateApply()` and the `WIN` filter are the
  newest, least-exercised code — verify them directly, and re-check after any change that
  touches the header, an input, or a render function.
- Channels shows Direct in the ~140 range at 30D (not ~585 — that would mean the dedupe broke).
- Board "Closed Won": three SEPARATE checks — do not collapse them.
    - Ceiling: must never exceed $1,178,260 in any window (summing/ordering bug).
    - Floor: must never be negative (ordering bug; `hsRange()` suspect fallback catches it).
    - Behaviour: the Closed Won HEADLINE is the all-time figure BY DESIGN, so it SHOULD read
      $1,178,260 in every window — that is correct, NOT the silent-all-time bug. The windowed
      movement lives in the subtitle ("$X won in <window>") and in the "Range: last N days
      (start -> end, N snapshots)" descriptor card above the KPIs. Proof the HubSpot window
      actually reaches `hsRange()`: switch 7D vs 30D and confirm the "Range:" descriptor
      changes (7D = shorter span AND fewer snapshots than 30D). If that descriptor is
      identical across 7D and 30D, the window filter is NOT reaching `hsRange()` and the tiles
      are silently showing all-time — that is the bug.
- History-depth expectation (state it, or it gets misreported as a bug): HubSpot and Clarity
  history only reach ~29 July, so 30D and 90D show IDENTICAL HubSpot/Clarity figures and an
  identical "Range:" descriptor — nothing older to include. GA4 reaches ~15 May, so
  GA4/Website Sessions DO differ across 30D vs 90D — use the Website tab to prove the global
  range control works, and 7D-vs-30D on Board to prove it reaches HubSpot. A Closed Won
  subtitle of "$0 won in last N days" is likewise a real answer (nothing closed in that
  window), not missing data.
- "Traffic quality · Clarity" card renders on the Website tab (above Behaviour) with HUMAN /
  BOT / BOT SHARE reading live from the Clarity payload (currently ~68 human / ~51 bot /
  ~43%). Confirm the numbers match `S.sources.clarity.data.metrics.traffic` and are NOT
  hardcoded; confirm the card is labeled by Clarity's own window (not the date range) and is
  not attached to the GA4 numbers.
- Insights tab: narrative headline + all-GA4 comparison cards (current, ↑/↓ vs prior 30d,
  baseline); Traffic-trend chart with a dashed trend line; an "HDI vs industry benchmark" table
  labelling each metric AHEAD/IN LINE/BEHIND; "Engagement by channel" bars (bar = engaged rate,
  tick = benchmark, n = sessions); an engagement-vs-benchmark trend chart; "Correlation &
  causation" (correlation stated, causation explicitly NOT claimed); "How to read GA4 vs
  Clarity"; the Clarity human-vs-bot table; a green "What leadership should take away" box; and a
  "Not yet measured" note (visitor→lead, sourced pipeline — data we don't collect yet, NOT red
  verdicts). Confirm every number is computed live (they move as data flows, nothing hardcoded),
  the benchmark POSITION labels are correct, and the channel bars/lever text match the data.
- Bot filter: the header "Include bots" toggle flips the Website → Behaviour "Sessions" figure
  AND the Insights "Website visitors" card between human-only (e.g. 68) and all-traffic (e.g.
  119 incl. bots), and updates the Traffic-quality filter line. Bot figures are plain COUNTS,
  not percentages (Human / Bot / Total). It must not alter any GA4 number.

## NEVER TOUCH
- The data engine site (`sweet-entremet-3ff236`) or its config. You only edit this repo.
- Do not trigger a snapshot run to "populate" a stub — Clarity has a hard 10-calls/day limit.
