# HDI Marketing Dashboard

Live display layer for Health Data Innovations' marketing analytics.
Auto-deploys from `main` → https://hdi-marketing-dashboard.netlify.app

**This repo is display only.** The data engine lives on a separate Netlify site
(`sweet-entremet-3ff236`) and holds the collectors, API tokens, and the history
database. Never deploy static files onto it — that can kill the live feed.

---

## Repo layout — all four are required

```
index.html              the entire dashboard: vanilla JS + inline CSS, no build step
netlify.toml            creates the /api/* proxy to the data engine
_redirects              same, belt and braces
data/benchmarks.json    benchmark ranges and approval state
```

`netlify.toml` and `_redirects` must stay at the repo **root**, and
`benchmarks.json` inside `data/`. Move or delete any of them and `/api/snapshots`
404s, which surfaces as a **FEED UNREACHABLE** banner.

The proxy exists so the browser only ever calls a same-origin path. Without it
the dashboard would need cross-origin headers on the engine site.

---

## Data sources

Three read-only endpoints. The dashboard never writes anything.

```
GET /api/snapshots
    current values for all sources

GET /api/snapshots?history=<source>&days=N
    dated history for trend lines
    source = hubspot | ga4 | clarity | linkedin

GET /data/benchmarks.json
    benchmark ranges and whether each is approved
```

### History response shape

```jsonc
{
  "source": "ga4",
  "days": 30,          // the integer you requested — NOT the data
  "rows": [            // iterate this
    {
      "date": "2026-08-11",
      "pulled_at": "2026-08-11T18:01:46Z",
      "data": {        // each row's real payload lives here
        "mode": "live",          // "stub" means no data for that date — skip the row
        "days": [ ... ],
        "channels": [ ... ],
        "top_pages": [ ... ]
      }
    }
  ]
}
```

Reading `.days` gives you the integer request parameter, not an array. Iterate
`.rows`, read `row.data`, and skip any row where `data.mode === "stub"`.

### Field names — live path

| Source | Fields |
|---|---|
| GA4 `days[]` | `date`, `provisional`, `sessions`, `engaged`, `key_events`, `engagement_seconds`, `new_users`, `total_users` |
| GA4 `channels[]` | `date`, `provisional`, `channel`, `sessions`, `engaged`, `key_events` |
| GA4 `top_pages[]` | `path`, `views`, `engagement_seconds` — **no date field** |
| Clarity `metrics{}` | `traffic`, `engagement_time`, `scroll_depth`, `rage_clicks`, `dead_clicks`, `quickback_clicks`, `script_errors` — an **object**, not a daily array |

Not `keyEvents`, not `engagedSessions`. Those strings appear only inside the
synthetic preview generator, where they are mapped to the real names on output.
Don't "fix" them there — the live path is already correct.

---

## The rule that causes silent wrong numbers

**Each snapshot contains a rolling window, so the same date appears in multiple
rows.** GA4 re-pulls its recent days as they settle. Concatenating rows across a
range therefore double-counts.

**`days` and `channels` both carry a `date`** — dedupe per date before summing.
When the same date appears twice, prefer the row where `provisional` is false;
if both match, prefer the later `pulled_at`. A date first seen as provisional
with 111 sessions and later settled at 115 should resolve to 115.

**`top_pages` has no `date`** — it is a snapshot-level rollup, not a daily row.
Take the latest snapshot only. Summing it across snapshots inflates every figure
by roughly the number of overlapping snapshots, and the result looks entirely
plausible, which is what makes it dangerous.

Label the panel "latest snapshot" so nobody reads it as a range total.

---

## Display rules — preserve these on every edit

- **Missing data renders as a dash, never a zero.** A dash says "we can't answer
  this." A zero claims the answer is none. They are different statements and the
  distinction is the point of this dashboard.
- **Never hardcode a metric into the live render path.** Preview mode may use
  synthetic values; the live path reads only from the feed.
- **GA4's two most recent days are `provisional`** — figures settle over roughly
  48 hours. Label them; don't present them as final.
- **Benchmarks are "reference until approved."** Approved means
  `hdi_target !== null` in `benchmarks.json`. An unapproved benchmark is
  context; an approved one is accountability.
- **Suppress rates computed on fewer than 8 records.** Show "not enough data"
  instead. A close rate on three deals is noise with a decimal point.
- **`key_events: 0` is real.** No conversions are marked as key events in GA4
  yet, so visitor-to-lead shows a dash. Rendering 0.00% would falsely claim
  nobody converts.
- **Marketing-sourced pipeline shows a dash, not `$0`.** No deal carries a
  campaign association, so the question is unanswerable rather than the answer
  being zero.

---

## Design system

Teal `#0F5C56` · lime `#C3D82B` · sage `#8ECAC4` · taupe `#A89C8E`
Background `#F6F5F1` · cards `#FFFFFF` with `#E3E1DB` borders

Archivo for display and body, IBM Plex Mono for data, labels, and source tags.

When a reference image is supplied, match its layout, hierarchy, chart style and
spacing. If an image conflicts with a rule above, ask before deviating.

---

## Making changes

```bash
git checkout -b describe-the-change
# edit index.html
git add -A && git commit -m "what changed"
git push -u origin describe-the-change
```

Open a PR. Netlify posts a Deploy Preview URL — review it against the reference
image, then merge to `main` to publish. Committing straight to `main` deploys to
production immediately.

### Verify every deploy

```bash
curl -s -o /dev/null -w "snapshots %{http_code} %{content_type}\n" \
  https://hdi-marketing-dashboard.netlify.app/api/snapshots
curl -s -o /dev/null -w "health    %{http_code} %{content_type}\n" \
  https://hdi-marketing-dashboard.netlify.app/api/health
```

Both must be **200** with content type **`application/json`**. `text/html` means
the proxy didn't apply and the request fell through to the page — which produces
a dashboard that loads cleanly and shows no data. That failure looks like a data
outage and is actually a file-placement problem.

Then open `/?v=NNN` with a fresh number and confirm: no FEED UNREACHABLE banner,
GA4 and Clarity panels showing live numbers, and the 7/30/90 control changing the
trend lines.

### Testing a variation without touching production

Copy the whole folder — keeping `netlify.toml`, `_redirects` and `data/` in
place — edit the copy, and deploy it as a new Netlify site. It reads the same
feed automatically. Same data, different look, no extra setup.

---

## Current state

| Source | Status |
|---|---|
| HubSpot | Live |
| GA4 | Live — history accumulating, `key_events` awaiting configuration in GA4 |
| Clarity | Live since 2026-08-11 18:01 UTC |
| LinkedIn | Awaiting first upload — `POST /linkedin-upload` with `X-Upload-Token` |

Clarity's API serves only the last three days, so its history exists **only**
because the pipeline stores it. Beyond that window the stored copy is the only
copy — which is why the engine site must not be redeployed casually.
