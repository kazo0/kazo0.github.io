---
title: "Uno Tidbit: Unicode Text Comes to the TextBox"
category: uno-tidbit
header:
  teaser: /assets/images/tidbit-unicode-textbox/hero.png
  og_image: /assets/images/tidbit-unicode-textbox/hero.png
tags: [uno-tidbits, uno-tidbit, tidbit, textbox, unicode, i18n, skia, uno-platform, uno, unoplatform]
---

Welcome to another edition of Uno Tidbits! In this series, we cover small, bite-sized topics that are handy to know when working with Uno Platform. Today's is a quick one, but it's a big deal if you build apps for a global audience: as of Uno Platform 6.5, the `TextBox` properly handles Unicode text for non-Latin scripts.

## The Problem

Text is deceptively hard. If your app only ever deals with English (or other Latin-script languages), it's easy to forget just how many assumptions are baked into "just show the text the user typed."

Other writing systems break those assumptions in a hurry:

- **Arabic** flows right-to-left.
- **Hindi** and other Indic scripts combine characters into ligatures.
- A single **grapheme cluster** — one "character" as a human perceives it — can span multiple Unicode code points.

If your text stack naively treats one code point as one character, all sorts of things go sideways: the caret lands in the wrong spot, selecting text with the mouse grabs half a character, and pressing the arrow key jumps into the middle of a glyph. Not exactly the polished experience you want to ship.

## The Solution

Uno Platform 6.5 tackles this head-on. The `TextBox` now renders non-Latin scripts — Mandarin, Arabic, Hindi, and anything else Unicode throws at it — with **proper caret positioning, text selection, and keyboard navigation**.

The details that matter in day-to-day use:

- **Mouse selection across multi-byte characters** works correctly, so dragging to select no longer chops a glyph in half.
- **Arrow keys move between grapheme clusters instead of code points.** In other words, one press of the arrow key moves you past one *character* as the user sees it, not one internal Unicode unit.

Under the hood, this is the Skia renderer's managed text stack doing the heavy lifting — leaning on industry-standard tooling like HarfBuzz for shaping and ICU for Unicode analysis to get the complex cases right. The nice part for us as app developers is that there's nothing new to wire up. It's a `TextBox`. You use it exactly as you always have; it just behaves correctly now for a much wider range of languages.

## One Caveat

There's one limitation worth flagging so you're not surprised: **Input Method Editors (IMEs) are not yet supported** in this release. If your keyboard outputs characters directly, you're good. But composition-based input for languages like Chinese, Japanese, and Korean — where you type a sequence and the IME composes the final characters — is still on the to-do list. So you can display and edit that text just fine; composing it with an IME is what's pending.

## Wrapping Up

Solid Unicode handling is one of those things you don't think about until it's missing, and then it's the only thing you can see. Getting caret positioning, selection, and keyboard navigation right for non-Latin scripts is a meaningful step toward Uno apps that feel native no matter where in the world they're running.

If you want the full rundown of everything that landed alongside this, check out the [Uno Platform 6.5 release post][uno-65-release]. And for a refresher on the control itself, the [`TextBox` docs][textbox-docs] are always a good bookmark.

Catch you in the next one :wave:

{% include links.md %}
