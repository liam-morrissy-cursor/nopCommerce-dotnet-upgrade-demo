#!/usr/bin/env bash
# Reset the nopCommerce .NET upgrade demo.
#
# Force-restores the `demo` branch (and `net6-baseline`) to pristine
# nopCommerce 4.50.4 (.NET 6) by triggering the "Reset upgrade demo"
# GitHub Actions workflow, then waits for it to finish. If run from
# inside a local clone of the demo repo, it also hard-resets your
# local `demo` branch to match.
#
# Usage:
#   ./demo-tools/reset-demo.sh [--prune] [--tag <upstream-tag>] [--repo <owner/name>]
#
#   --prune   Also delete branches created during a previous demo run
#             (everything except main/demo/net6-baseline).
#   --tag     Use a different upstream nopCommerce tag as the baseline
#             (default: release-4.50.4, the last .NET 6 release).
#   --repo    Target a different copy of the demo repo.
#
# Requires the GitHub CLI (`gh`), authenticated with access to the repo.

set -euo pipefail

REPO="${DEMO_REPO:-liam-morrissy-cursor/nopCommerce-dotnet-upgrade-demo}"
WORKFLOW="reset-demo.yml"
BASELINE_TAG="release-4.50.4"
PRUNE="false"

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)   BASELINE_TAG="$2"; shift 2 ;;
    --repo)  REPO="$2"; shift 2 ;;
    --prune) PRUNE="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: the GitHub CLI (gh) is required. Install it from https://cli.github.com/ and run 'gh auth login'." >&2
  exit 1
fi

echo "Triggering demo reset on ${REPO} (baseline ${BASELINE_TAG}, prune=${PRUNE})..."
gh workflow run "$WORKFLOW" --repo "$REPO" \
  -f baseline_tag="$BASELINE_TAG" \
  -f prune_extra_branches="$PRUNE"

echo "Waiting for the workflow run to start..."
sleep 8
RUN_ID=$(gh run list --repo "$REPO" --workflow "$WORKFLOW" --limit 1 --json databaseId --jq '.[0].databaseId')
echo "Watching run ${RUN_ID} (mirroring the upstream history usually takes a few minutes)..."
gh run watch "$RUN_ID" --repo "$REPO" --exit-status

# If we're inside a local clone of the demo repo, sync it too.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && git remote get-url origin 2>/dev/null | grep -qi "${REPO}"; then
  echo "Local clone detected — syncing local demo branch..."
  git fetch origin demo net6-baseline
  git checkout demo
  git reset --hard origin/demo
  git clean -fd
fi

echo "Demo reset complete: 'demo' branch is back to nopCommerce ${BASELINE_TAG}."
