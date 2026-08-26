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

Last substantive update: 2026-08-24 — Verona 1:1 dashboard changes (below).

## AUG 24 (Verona 1:1) — load-bearing changes, do not regress
- **`trend()` now draws Y-AXIS NUMBERS** on every chart (`.axy` labels at each gridline via
  `axfmt`). Critical per Verona ("could be 10 or 1,000"). Also supports **`opts.prior`** — a
  taupe dashed prior-period overlay line — and **clamps the axis floor at 0** for non-negative
  data (no "-6 sessions"). Keep all three.
- **Prior-period overlay** is wired on the Insights traffic-trend and Website "Sessions over
  time" charts via `opts.prior = W.pri.map(d=>d.sessions)`.
- **Header title is just "Marketing performance"** (the "one source of truth" subtitle was
  removed — the integrity note still lives in the page footer).
- **`benchLegend()`** (lime = clears benchmark / sage = under benchmark colour dots) sits under
  both channel-engagement charts. Keep it.
- **"Traffic quality" renamed:** the Website human/bot panel is **"Human vs bot traffic ·
  Clarity"**; the Insights stored-history one is **"Traffic over time · Clarity"** (it's a
  quantity chart, not a quality score).
- **LinkedIn tab reordered** into an AUDIENCE group (followers over time → unique visitors →
  demographics) then an ENGAGEMENT group (engagement rate → impressions → by content type →
  benchmark) — engagement and audience are no longer interleaved.
- **LinkedIn "Who engaged with my content" REMOVED** (Verona: HubSpot handles prospect
  qualification). Do not re-add it; the engager-filter code is gone.
- **LinkedIn post archive is sortable + expandable:** globals `LI_SORT`/`LI_DIR`/`LI_MORE`,
  clickable column headers call `window.LIsort(col)`, "See all" calls `window.LImore()`. Keep
  the window.* handlers (inline onclick needs them global).
- **Blog:** `erTxt()` suppresses the engagement % on posts with < 5 sessions (shows "too few to
  rate" — a 0% on 3 visitors is noise, not a result); the low list is "Lowest-**traffic** posts"
  ranked by sessions with a small-sample caveat; `shortTitle()` truncates titles at a word
  boundary (no mid-word cut).
- **Headlines are data-honest** (Henry Aug 24): the Insights headline is graded by month-over-month
  (climbing ≥25% / up ≥8% / holding steady / down ≤-8% / "Website performance ·" when no prior) — it
  never asserts "compounding". LinkedIn headline is "The LinkedIn audience keeps growing." Don't
  reintroduce "compounding".
- **Bar labels no longer clip:** `.row` label column widened and `.row .lb` wraps
  (`white-space:normal; overflow-wrap:anywhere`) so long metro names / titles show in full.
- STILL PENDING (needs data from Verona): 2-year GA backfill; LinkedIn historical follower +
  post-level spreadsheets. And organic search-terms drill-down needs Google Search Console.

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
- `clarityWindow()` — sums human (`totalSessionCount`) and bot (`totalBotSessionCount`)
  across every stored Clarity day that falls inside the selected window `WIN`, dedup'd to
  one row per day (freshest `pulled_at` wins). This is what feeds the HUMAN / BOT / TOTAL
  headline KPIs and the split bar, so the panel uses the SAME timeframe as the rest of the
  page (Verona A5, Aug 17). Returns null when no stored day is in range.
- `clarityAgg(hist)` — averages the behaviour metrics (scroll depth, rage/dead/quick-back
  %, active engagement, script errors) across the windowed stored days, so the "Behaviour ·
  Clarity" card MOVES with the date filter instead of showing the latest single day (fixes
  Henry's "1 day clarity data" report, Aug 17). These are per-session %/seconds, so the daily
  mean is the correct roll-up; the card is labelled "avg over <range> · N days with data".
- `clarityTraffic(c)` — reads the LATEST snapshot's `metrics.traffic` plus the "Traffic"
  slice of `dimensions.channel_country` and `dimensions.os_browser_device`. Still used for
  the bot-concentration + device-fingerprint callouts (those exist only on the latest
  snapshot, not per stored day). Returns null unless both session counts are numeric.
- The render block in `website()` draws HUMAN / BOT / TOTAL VISITORS KPIs (plain counts, no
  percentages — Henry's call), the human-vs-bot split bar, and the foot notes.

Rules specific to this panel:
- Headline totals come from `metrics.traffic` (authoritative). The per-bucket dimension
  slice can sum slightly differently — a known Clarity quirk; do not "reconcile" them by
  summing the dimension rows into the headline.
- The headline counts ARE windowed to `WIN` via `clarityWindow()` (A5). We only have a few
  days of stored Clarity history so far, so 7/30/90 may show the same sum until more days
  accumulate — that is correct, not a bug. The bot-concentration callout stays latest-
  snapshot-only. Label the panel with `winDesc()`.
- Keep it Clarity-scoped and separate from GA4. GA4 applies its own server-side bot
  filtering, so never imply the GA4 Sessions number carries this bot share.
- Never hardcode the counts. If Clarity returns no bot field, the card must disappear, not
  show a stale/zero number.

## BENCHMARKS TAB — no approval/target column
The Benchmarks table shows Metric / Industry range / HDI now only. The old "Target" column and the
"unapproved" verdict were REMOVED (Henry Aug 19: leadership doesn't need the internal approval state).
Benchmarks are context shown beside HDI's figure — keep it neutral, no pass/fail.

## DO NOT REMOVE — THE LINKEDIN TAB + ACCUMULATING MANUAL UPLOAD (load-bearing)
LinkedIn is a **manual upload with ACCUMULATING HISTORY** (schema 2). Data lives in
**`data/linkedin.json`** → global **`LI`**, served at `/data/linkedin.json`, fetched in `load()`.
Shape: `seed_trends` (historical backfill reconstructed from the exec deck), `post_types`,
`benchmark`, and **`uploads[]`** — one object per monthly export, **RETAINED forever**.
- **To add a month: APPEND one object to `uploads` — NEVER replace the array.** That is what
  keeps history. Each upload carries `period`, `month` (e.g. "Aug '26"), `engagement_rate`,
  `profile`, `followers`, `posts[]`, `engagers[]`, `demographics_location[]`.
- `linkedin()` uses the LATEST upload for current KPIs / content table / engagers / demographics,
  and builds trends from **seed + every upload**: Followers over time (`seed.followers_monthly` +
  each upload's `followers.total`), Engagement rate over time (`seed.engagement_monthly` + each
  upload's `engagement_rate`, vs the 1–3% industry line), Impressions per month (uploads, ≥2 pts),
  and Unique visitors (historical seed). It also renders a **"Post archive — individual performance
  over time"** table (union of every upload's posts) and a **"History is stored, not overwritten"**
  box showing the count of stored periods. Keep all of these.
- Numbers come ONLY from `data/linkedin.json` — never hardcode LinkedIn metrics into index.html.
- "Who engaged with my content" shows QUALIFIED EXTERNAL engagers only (Henry Aug 19): `linkedin()`
  filters out HDI team members (title/company matches HDI / Health Data Innovations, or `internal:true`)
  and job-seekers (`job_seeker:true`, an "open to work/seeking" title, or `reacted_post_type:"job"`),
  plus any engager with `exclude:true`. Keep that filter; it's a sales-signal list, not a reaction dump.
- `shell()` marks `m.linkedin="live"` when `LI` is present so the "never received an upload" banner
  does not fire. Keep that guard.
- Verona confirmed LinkedIn is Phase 1. If the pipeline ever delivers a live feed, prefer
  `S.sources.linkedin`; until then `LI`.

## DO NOT REMOVE — THE BLOG TAB (load-bearing)
Tab "Blog" (`data-t="blog"`, pane `#p-blog`), rendered by `blog()`, between Website and LinkedIn.
Verona's dedicated thought-leadership view (Aug 17: "blog should have its own tab… top blog posts
because we need to see which posts are gaining traction"). It ranks blog posts by sessions from the windowed
`HIST.ga4_agg.landing_pages`. Blog posts now live at **`www.hd-innovations.com/resources/[title]`** (Meg+Adrian
shipped the permalink + redirects). `isBlogPath()` accepts BOTH `/resources/[slug]` and legacy
root-level content slugs still in GA4 history, while excluding nav pages (`SITE` list), `.php`
legacy pages, and `/category/` + `/tag/` archives. Shows POSTS WITH TRAFFIC / TOTAL BLOG SESSIONS /
TOP POST / RESOURCES HUB VIEWS, a "Top blog posts" bar list and a "Lowest-traction posts" list,
each post linked to its canonical `/resources/` URL via `blogLink()`. Driven by the date filter.
Keep `isBlogPath` and the `/resources/` link normalisation. `blog()` is called in `render()`.

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
- The metric CARDS (both tabs) lead with the period-over-period % change ("↑ +22% vs prior N
  days"); the secondary note gives the prior-period value FIRST ("was 32% · industry reference
  52–56%") because Verona said the prior period is the more important number, benchmark second.
  Cards are coloured by direction of change, not benchmark position.
- The words "behind" AND "below the benchmark" are BANNED everywhere user-facing (Verona Aug 17;
  Henry Aug 19). The Insights "HDI vs the industry reference" table shows HDI-now beside the
  industry range with NO verdict column. The takeaway box says "Engagement is climbing", never
  "below the benchmark". Keep it neutral — the site relaunched recently and is still ramping.
- The ~158s "avg engaged time" benchmark was REMOVED (Henry Aug 19): 158s is session DURATION
  (old Universal Analytics), not GA4 average-engagement-time-per-session (~30–90s). Do not re-add
  it. The AVG ENGAGED TIME card shows current vs prior only, note "avg active seconds per visit".
  `GA4_SESS_BENCH`/`sessBench` are now unused; the 52–56% engagement-rate reference stays.
- Channel bars (both tabs) show engaged rate as the bar, coloured lime when the channel clears
  the benchmark and sage when below — there is NO black benchmark tick mark on the bars (Verona
  Aug 17: "these black marks need to go"). Do not re-add the per-bar tick (`i[4]` in bars()).
- Every channel chart is followed by `channelLegend(names)` — plain-language definitions of the
  GA4 default channel groups (Direct / Organic Search / Unassigned / AI Assistant / …) plus what
  `n` and the `%` mean (Henry Aug 17: the raw labels "have no context"). Keep the legend on any
  channel chart. `CHANNEL_DEF` holds the definitions.
- Page paths link to the live page via `pageLink(path)` → `SITE_URL + path` (SITE_URL =
  https://www.hd-innovations.com — HDI's true site, NOT hdi.com; change there if it moves). Used on Top pages, Landing pages, and Blog.
  `pageLink` renders GA4 placeholders like "(not set)" as plain grey text, not broken links.
- `bars()` accepts an optional `i[6]` = raw-HTML label (used for clickable page links); when
  absent it falls back to `esc(i[0])`. Don't remove the `i[6]` branch.
- The Website tab has a "Landing pages — what's bringing people in" card fed by
  `HIST.ga4_agg.landing_pages` (aggregated in `aggGA4` from the dated `landing_pages` dimension —
  sessions/engaged per entry page over the window, with engagement rate). This is the "what's
  driving sessions" view (Henry Aug 17). "Top pages" shows most-viewed pages + `s/view` (avg
  engaged seconds per view = performance). Keep both.
- NOT in the feed yet (flagged in the channels card, needs a data-layer addition, NOT a display
  fix): landing-page × channel cross-tab ("which pages each channel drives"), per-page traffic
  source, and GSC keywords. Do not fabricate these — they require the data engine to pull the
  extra GA4/GSC reports. The data engine is off-limits from this repo.
- The Insights engagement-trend chart is "Engagement trend over time" with only a dashed
  regression trend line — no on-chart benchmark reference line (removed per Verona A4). Don't
  re-add a benchmark line or rename it "vs benchmark".
- `trend(series, opts)` supports `opts.trendline` (dashed regression) and `opts.benchmark`
  (dashed reference line). EVERY line chart carries `trendline:true` (Verona A3). The on-chart
  `benchmark` reference line was REMOVED from the engagement-trend chart (Verona A4: an
  unlabelled ~50% line confused the read); benchmark context now lives in the table + card
  notes, not as a bare line. Keep `trendline` on all charts.
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
