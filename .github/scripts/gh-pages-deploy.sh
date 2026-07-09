#!/usr/bin/env bash
#
# DIY GitHub Pages publisher for the `gh-pages` branch — no third-party actions.
#
# Publishes a built site into a subtree of `gh-pages` (or its root for
# production) while leaving every sibling subtree untouched. This is what lets a
# production site and any number of PR previews coexist on the same branch:
#
#   gh-pages/
#     index.html            <- production (DEST_DIR="")
#     CNAME .nojekyll ...
#     previews/
#       pr-12/  ...          <- preview  (DEST_DIR="previews/pr-12")
#       pr-15/  ...
#
# Environment inputs:
#   MODE        deploy | remove                     (default: deploy)
#   DEST_DIR    subtree on gh-pages; "" = prod root
#   SOURCE_DIR  built site to publish               (required when MODE=deploy)
#   GITHUB_TOKEN / GITHUB_REPOSITORY / GITHUB_SHA   (provided by Actions)
#
set -euo pipefail

MODE="${MODE:-deploy}"
DEST_DIR="${DEST_DIR:-}"
SOURCE_DIR="${SOURCE_DIR:-}"
BRANCH="gh-pages"
REMOTE="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

if [ "$MODE" = "deploy" ] && [ -z "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR is required when MODE=deploy" >&2
  exit 1
fi
if [ "$MODE" = "remove" ] && [ -z "$DEST_DIR" ]; then
  echo "refusing to remove the production root" >&2
  exit 1
fi

# Resolve the source to an absolute path (publish() runs from a temp dir).
if [ "$MODE" = "deploy" ]; then
  SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
fi

# One attempt: clone the current branch, splice in the new files, push.
# Re-cloning per attempt means a concurrent deploy (prod vs. preview) is picked
# up on retry instead of being clobbered.
publish() {
  local tmp
  tmp="$(mktemp -d)"

  if git ls-remote --exit-code --heads "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
    git clone --quiet --branch "$BRANCH" --single-branch --depth 1 "$REMOTE" "$tmp"
  else
    if [ "$MODE" = "remove" ]; then
      echo "Branch $BRANCH does not exist; nothing to remove."
      rm -rf "$tmp"
      return 0
    fi
    # First ever deploy: start an empty orphan branch.
    git clone --quiet --depth 1 "$REMOTE" "$tmp"
    git -C "$tmp" checkout --quiet --orphan "$BRANCH"
    git -C "$tmp" rm -rfq . 2>/dev/null || true
  fi

  git -C "$tmp" config user.name "github-actions[bot]"
  git -C "$tmp" config user.email "41898282+github-actions[bot]@users.noreply.github.com"

  local msg
  if [ "$MODE" = "remove" ]; then
    rm -rf "${tmp:?}/${DEST_DIR}"
    msg="chore(preview): remove ${DEST_DIR}"
  elif [ -z "$DEST_DIR" ]; then
    # Production: replace root-level files but keep previews/ (and .git).
    find "$tmp" -mindepth 1 -maxdepth 1 \
      ! -name '.git' ! -name 'previews' -exec rm -rf {} +
    cp -a "$SOURCE_DIR"/. "$tmp"/
    touch "$tmp/.nojekyll"
    msg="deploy: production @ ${GITHUB_SHA:0:7}"
  else
    # Preview: replace just this subtree.
    rm -rf "${tmp:?}/${DEST_DIR}"
    mkdir -p "$tmp/$DEST_DIR"
    cp -a "$SOURCE_DIR"/. "$tmp/$DEST_DIR"/
    touch "$tmp/.nojekyll"
    msg="deploy: ${DEST_DIR} @ ${GITHUB_SHA:0:7}"
  fi

  git -C "$tmp" add -A
  if git -C "$tmp" diff --cached --quiet; then
    echo "No changes to publish."
    rm -rf "$tmp"
    return 0
  fi

  git -C "$tmp" commit --quiet -m "$msg"
  if git -C "$tmp" push --quiet origin "HEAD:$BRANCH"; then
    echo "Published: $msg"
    rm -rf "$tmp"
    return 0
  fi

  echo "Push rejected (branch moved underneath us)."
  rm -rf "$tmp"
  return 1
}

for attempt in 1 2 3 4 5; do
  if publish; then
    exit 0
  fi
  echo "Retrying (attempt ${attempt}/5)…"
  sleep $((attempt * 3))
done

echo "Failed to publish to ${BRANCH} after 5 attempts." >&2
exit 1
