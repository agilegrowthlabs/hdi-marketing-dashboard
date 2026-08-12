# Finish the Git setup — ~3 minutes, when you're back at your computer

Everything is prepped. The dashboard repo (with the current enhanced files + history) is
built and waiting; the only thing I couldn't do without you is authenticate as you.

## What YOU do (the only manual step)
1. In the GitHub tab I left open, **sign in** (or click "Create an account" — free, ~1 min).
2. Land on your GitHub dashboard, then tell me **"go, I'm logged into GitHub as <username>"**.

That's it. Everything below is me.

## What I do the moment you say go (no steps from you)
1. Mint a short-lived GitHub token in your logged-in session (repo scope), read it, and use it
   only in my sandbox — then delete it right after, same as I did with the Netlify deploy token.
2. Create the **private** repo `hdi-marketing-dashboard` in your account and push the ready
   local repo (full commit history) to it — via the prepped `finish-git.sh`.
3. In Netlify → the dashboard site → **Build & deploy → link to a Git repository**, authorize
   GitHub, pick the repo, set publish dir `.` (no build command — it's static). I'll drive the
   authorize click; you may get one GitHub app-install prompt to approve if it appears.
4. Make a tiny test commit and confirm Netlify auto-builds and the live site still verifies
   (`/api/snapshots` 200, no FEED UNREACHABLE).
5. Hand you + the other environment the clone-edit-push snippet (below).

## After that — how the other Claude environment edits (zero-issue)
```bash
git clone https://github.com/<username>/hdi-marketing-dashboard.git
cd hdi-marketing-dashboard
# edit index.html for visuals (start from THIS file — it has the GA4/Clarity fixes)
git checkout -b visual-change
git add -A && git commit -m "describe the visual change"
git push -u origin visual-change
# open the PR / branch — Netlify posts a PREVIEW URL to review before going live
# merge to main -> Netlify auto-deploys to production
```
Rules to keep (already in the repo README): edit only `index.html`; keep `netlify.toml` +
`_redirects` at the root; never hardcode metrics; no data shows a dash, never a zero.

## If you'd rather use an Org instead of your personal account
Tell me the org name when you say go and I'll create the repo there instead (cleaner for an
agency; transfers to the client later stay easy either way).

## Backup
`hdi-dashboard.gitbundle` in this folder is the full repo (history included). If anything ever
goes sideways, `git clone hdi-dashboard.gitbundle hdi-marketing-dashboard` reconstructs it.
