# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal blog at [kazo0.dev](https://kazo0.dev) — a Jekyll site about .NET and Uno Platform development. Built with the [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) remote theme (dark skin) and deployed via GitHub Pages.

All Jekyll source lives under `docs/`. Run all commands from there.

## Commands

```bash
# Serve locally with live reload
cd docs && bundle exec jekyll serve

# Build static site
cd docs && bundle exec jekyll build

# Serve drafts (posts in _drafts/) alongside published posts
cd docs && bundle exec jekyll serve --drafts

# Install/update gems
cd docs && bundle install
cd docs && bundle update
```

## Architecture

### Content

- **`_posts/`** — Published posts. File naming: `YYYY-MM-DD-slug.md`. Post dates must be in the past/present to be published.
- **`_drafts/`** — Work-in-progress posts with no date in the filename. Only visible with `--drafts`.
- **`assets/images/`** — Post images, organized in per-post subdirectories (e.g., `assets/images/chefs-login/`).

### Post Frontmatter

Every post uses this structure:

```yaml
---
title: "Post Title"
category: uno-general
header:
  teaser: /assets/images/<post-slug>/hero.png
  og_image: /assets/images/<post-slug>/hero.png
tags: [tag1, tag2]
---
```

The `layout`, `read_time`, `show_date`, `author_profile`, `related`, and `toc` fields are set globally in `_config.yml` defaults and don't need to be repeated per post.

### Shared Links

Reusable link references are defined in `_includes/links.md`. Include them in posts with `{% include links.md %}` at the bottom, then reference them inline as `[text][link-id]`.

### Theme Customization

- **`_sass/custom_styles.scss`** — Custom CSS overrides for the Minimal Mistakes theme.
- **`_layouts/single.html`** — Extends the theme's default single layout (adds hero image rendering before content).
- **`_data/navigation.yml`** — Site navigation links.

### Linting & Commits

This repo enforces **markdownlint** and **Conventional Commits** via git hooks (husky) and GitHub Actions (`.github/workflows/lint.yml`). The Node tooling lives at the repo root, separate from the Jekyll/Ruby toolchain under `docs/`.

```bash
npm install         # run once: installs tooling and activates the git hooks
npm run lint:md     # lint all markdown
npm run lint:md:fix # auto-fix markdown issues
```

- **markdownlint** config: `.markdownlint-cli2.jsonc` (root, single source of truth). Disables MD013 (line length), MD033 (inline HTML), MD052 (reference links); sets MD024 to `siblings_only`. `docs/_includes/links.md` is ignored because its reference definitions resolve cross-file (see [Shared Links](#shared-links)).
- **Commits** must follow [Conventional Commits](https://www.conventionalcommits.org/) (config: `commitlint.config.js`; subject case is unrestricted). The `commit-msg` hook validates messages locally; CI re-checks PR commits.
- The `pre-commit` hook runs markdownlint (with `--fix`) on staged markdown via lint-staged.
- Grammarly is configured in `.vscode/settings.json` for markdown files.

### Embeds

Jekyll shortcodes for media:

- YouTube: `{% include video id="VIDEO_ID" provider="youtube" %}`
- Google Drive: `{% include video id="FILE_ID" provider="google-drive" %}`
- Images with captions: use `<figure>/<figcaption>` HTML blocks

### Notices

Callout boxes use Minimal Mistakes notice classes appended after a paragraph:

```markdown

Some warning text.
{: .notice--warning}

```

Available: `notice--info`, `notice--warning`, `notice--danger`, `notice--success`.
