#!/usr/bin/env python3
"""Strip duplicated images out of a PR preview build.

A preview is a full copy of the site published under gh-pages/previews/pr-N/.
Copying `assets/images` along with it duplicates ~270 MB per preview, and since
the Pages deployment artifact is the *whole* gh-pages branch, a handful of open
PRs is enough to blow past the 1 GB limit.

Only the images a PR actually adds or edits are new. Every other image is
already live at the production root of the same origin, so the preview can just
point at it. This script rewrites the built HTML accordingly and then deletes
the images the preview no longer references.

Image URLs reach the build in two shapes, and both are handled in one pass so a
rewrite can never be applied twice:

    /assets/images/foo.png                  hand-written in post markdown
    /previews/pr-N/assets/images/foo.png    emitted by the theme via baseurl

Usage: preview-slim.py SITE_DIR BASE_PATH KEEP_LIST
  SITE_DIR   built site (e.g. _site)
  BASE_PATH  preview prefix (e.g. /previews/pr-34)
  KEEP_LIST  file of image paths relative to assets/images/, one per line
"""

import os
import re
import sys

PREFIX = "/assets/images/"


def main(site_dir, base, keep_list):
    base = base.rstrip("/")
    with open(keep_list, encoding="utf-8") as fh:
        keep = {line.strip() for line in fh if line.strip()}

    # Optionally consume an existing preview prefix so re-pointing an already
    # prefixed URL replaces it rather than stacking a second copy in front.
    pattern = re.compile(
        "(?:" + re.escape(base) + ")?" + re.escape(PREFIX) + r"([^\"'\s>),]+)"
    )

    def repoint(match):
        path = match.group(1)
        # Tolerate the odd `/assets/images//foo.png` written in a post: keep the
        # URL byte-for-byte, but normalise before testing it against the keep set.
        prefix = base if path.lstrip("/") in keep else ""
        return prefix + PREFIX + path

    rewritten = 0
    for root, _, files in os.walk(site_dir):
        for name in files:
            if not name.endswith(".html"):
                continue
            path = os.path.join(root, name)
            with open(path, encoding="utf-8") as fh:
                before = fh.read()
            after = pattern.sub(repoint, before)
            if after != before:
                with open(path, "w", encoding="utf-8") as fh:
                    fh.write(after)
                rewritten += 1

    images_dir = os.path.join(site_dir, "assets", "images")
    removed = kept = 0
    for root, _, files in os.walk(images_dir):
        rel_dir = os.path.relpath(root, images_dir)
        for name in files:
            rel = name if rel_dir == "." else os.path.join(rel_dir, name)
            if rel.replace(os.sep, "/") in keep:
                kept += 1
            else:
                os.remove(os.path.join(root, name))
                removed += 1
    # Prune the directories those files left behind (deepest first).
    for root, dirs, files in os.walk(images_dir, topdown=False):
        if not dirs and not files and root != images_dir:
            os.rmdir(root)

    print(f"HTML files rewritten: {rewritten}")
    print(f"Images bundled with this preview: {kept}")
    print(f"Images left to the production root: {removed}")

    missing = sorted(k for k in keep if not os.path.exists(os.path.join(images_dir, k)))
    if missing:
        # Not fatal — a keep entry can name an image the PR deleted or that
        # Jekyll excludes — but it is worth seeing in the log.
        print(f"warning: {len(missing)} kept image(s) absent from the build:")
        for k in missing[:10]:
            print(f"  {k}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
