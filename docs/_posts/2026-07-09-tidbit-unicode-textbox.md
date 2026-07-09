---
title: "Uno Tidbit: Unicode Text Comes to the TextBox"
category: uno-tidbit
header:
  teaser: /assets/images/tidbit-unicode-textbox/hero.png
  og_image: /assets/images/tidbit-unicode-textbox/hero.png
tags: [uno-tidbits, uno-tidbit, tidbit, textbox, unicode, i18n, skia, uno-platform, uno, unoplatform]
---

Welcome to another edition of Uno Tidbits! In this series, we will be covering small, bite-sized topics that are useful to know when working with Uno Platform. These will be quick reads that you can consume in a few minutes and will cover a wide range of topics. Today, we are going to cover a small but mighty improvement that landed in Uno Platform 6.5: the `TextBox` now properly handles Unicode text for non-Latin scripts.

## The Problem

Text is deceptively hard. If your app only ever deals with English (or other Latin-script languages), it's easy to forget just how many assumptions are quietly baked into "just show the text the user typed."

Other writing systems break those assumptions in a hurry. Arabic flows right-to-left. Hindi and other Indic scripts combine characters into ligatures. And a single grapheme cluster (one "character" as a human perceives it) can span multiple Unicode code points.

When a text stack naively treats one code point as one character, things go sideways fast. The caret lands in the wrong spot, dragging to select grabs half a glyph, and tapping the arrow key jumps you into the middle of a character. If you've ever watched a caret land three glyphs away from where you actually clicked, you know exactly how maddening that is.

## The Solution

Uno Platform 6.5 tackles this head-on. The `TextBox` now renders non-Latin scripts (Mandarin, Arabic, Hindi, and anything else Unicode throws at it) with the behavior you'd expect out of a native text field.

The best part is that there's nothing new to learn. It's still just a `TextBox`:

```xml
<TextBox PlaceholderText="اكتب اسمك هنا" />
```

You use it exactly as you always have. It just behaves correctly now for a much wider range of languages. A few specifics that matter day-to-day:

- **Caret positioning**: the cursor lands where you'd expect, even mid-word in a complex script.
- **Selection**: dragging across multi-byte characters no longer chops a glyph in half.
- **Keyboard navigation**: arrow keys move you past one whole character at a time (one grapheme cluster) instead of stepping through the internal Unicode units.

Under the hood, this is the Skia renderer's managed text stack doing the heavy lifting, leaning on battle-tested tooling like HarfBuzz for shaping and ICU for Unicode analysis to get the tricky cases right. As app developers, we get all of that for free.

## One Caveat

There's one limitation worth flagging so you're not caught off guard. Input Method Editors (IMEs) are NOT supported yet in this release. If your keyboard outputs characters directly, you're good to go. But composition-based input for languages like Chinese, Japanese, and Korean, where you type a sequence and the IME assembles the final characters, is still on the to-do list. So you can display and edit that text just fine. Composing it with an IME is what's pending.

## Conclusion

Solid Unicode handling is one of those things you don't think about until it's missing, and then it's the only thing you can see. Getting the caret, selection, and navigation right for non-Latin scripts is a meaningful step toward Uno apps that feel native no matter where in the world they're running.

If you want the full rundown of everything that landed alongside this, check out the [Uno Platform 6.5 release post][uno-65-release]. And for a refresher on the control itself, the [`TextBox` docs][textbox-docs] are always a good bookmark.

Catch you in the next one :wave:

{% include links.md %}
