#!/usr/bin/env bash
# Run in the Cowork sandbox AFTER Henry is logged into GitHub and a token is available.
# Creates the private repo via the GitHub API and pushes the ready local repo.
#   GITHUB_TOKEN = a fresh PAT with 'repo' scope (minted in the browser, deleted after)
#   GITHUB_USER  = Henry's GitHub username (or org, e.g. agile-growth-labs)
set -euo pipefail
: "${GITHUB_TOKEN:?set GITHUB_TOKEN}"; : "${GITHUB_USER:?set GITHUB_USER}"
REPO="hdi-marketing-dashboard"
# create private repo (user repo; for an org use POST /orgs/<org>/repos)
curl -sS -X POST https://api.github.com/user/repos \
  -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" \
  -d "{\"name\":\"${REPO}\",\"private\":true,\"description\":\"HDI marketing dashboard (Netlify continuous deploy)\"}" \
  | grep -E '"full_name"|"message"' || true
cd /tmp/hdi-repo
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO}.git"
git push -u origin main
echo "PUSHED -> https://github.com/${GITHUB_USER}/${REPO}"
