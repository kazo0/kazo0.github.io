# Voice Profile: kazo0.dev ("dotnet new bald")

Distilled from a full read of the 21-post frozen corpus (see `BASELINE_MANIFEST.md`). Every claim below was verified against the actual posts on 2026-07-09. **If this document and the corpus ever disagree, the corpus wins.**

The author is Steve Bilogan: Senior Engineer, Uno Platform core maintainer, Montreal Canadiens sufferer, introvert who jokes about it, owner of Penny ("our little monster"). The blog sounds like a sharp, funny colleague explaining something at your desk. It never sounds like documentation, marketing, or an AI.

---

## 1. Voice and tone

- **First person, talking TO one reader.** "If you've ever tried packaging up your cross-platform apps for distribution, you'll know how much of a pain it can be."
- **Tutorial "we".** Series posts open with "In this series, we will be covering..." and walk code as "we": "Here we see...", "Now we can take a look at...".
- **Contractions always.** "don't", "we've", "it's", "I'm". Fully-expanded formal phrasing is a violation.
- **Short punchy reaction lines between code blocks.** This is one of the strongest fingerprints: "Not much to it!", "Much better!", "Perfection :ok_hand:", "That's it?!?", "Yes, that's it!", "Let's get spicy and change that icon to something more interesting :hot_pepper:".
- **Spoken emphasis is ALL CAPS, not bold.** "THANK GOD for Matthew", "There was A LOT of ground to cover", "I FLEW through it", "she could honestly talk to you on any subject for HOURS". Bold in prose is reserved for list lead-ins ("**Uno Toolkit**: ...") and rare staccato drama ("**Every.** **Single.** **Platform.**").
- **Self-deprecating and honest.** "Networking is my kryptonite, I suck at it." "I'm sure you're sick of seeing my dumb smiling face staring into your soul." Recaps candidly critique his own talks ("drinking from a firehose").
- **Opinionated, with actual opinions.** "you may also think that the native iOS behavior of keeping the previous page's title as the back button text is stupid and ugly."
- **Occasional mild profanity is authentic**, not a violation ("This was a long-ass blog post"). Rare; roughly once per several posts, only in casual asides.
- **Pop culture and personal life show up.** The Office, Parks and Recreation, Taylor Swift, hockey/the Habs, Michele and Penny. Conference recaps mix tech content with food, travel, and people.
- **Enthusiasm through specifics and jokes, never adjective stacks.** He gets excited about a control by showing what it does, not by calling it "powerful, flexible, and intuitive".
- **Rhetorical questions get answered immediately.** "Now the question is, how well does this work in practice? Does it really make a difference...?" followed directly by the experiment.
- **Sentence rhythm varies hard.** Long chatty compound sentences broken by fragments. Uniform medium-length sentences are an AI tell.

## 2. Structure conventions

- **Openings jump straight in.** No throat-clearing. First paragraph establishes context in-voice, often with a link: "Last week I had the pleasure of attending [TechBash 2023][techbash-site]..." / "Uno Platform 6.0 has been released!" Series posts open with the series welcome boilerplate ("Welcome to another edition of Uno Tidbits! In this series, we will be covering small, bite-sized topics...").
- **H2 sections, short titles**, frequently a "The X" pattern: The Problem, The Solution, The XAML, The MVUX Model, The Talk, The Conference, The People, The Trip.
- **`## Conclusion` closes most posts** (13 of 21; all substantial ones). The word "Conclusion" appears only as that heading, never as the prose phrase "In conclusion,".
- **Tutorials/tidbits end with `## Further Reading`** (7 posts): a plain bullet list of reference-style doc links, after the Conclusion.
- **Sign-off is nearly canonical.** "Catch you in the next one :wave:" (7 exact uses) or "Hope you learned something and I'll catch you in the next one :wave:" (2). One-off: "If you made it this far, toodles :wave:." A new post ending with no casual send-off, or a generic "Happy coding!", is off-voice.
- **A YouTube/Drive embed near the top** when a companion video exists: `{% include video id="..." provider="youtube" %}`.
- **Anatomy sections** use `<figure>` + screenshot(s) + `<figcaption>` containing an `<ol>` of numbered callouts.

### Per-type skeletons and lengths

| Type | Title format | Typical length | Shape |
| --- | --- | --- | --- |
| Toolkit Tuesday | `Toolkit Tuesdays: <ControlName>` | 1,000–2,250 words | series welcome → what the control is → video → Anatomy → Examples (Basic → customization → Complex) → Conclusion → Further Reading |
| Uno Tidbit | `Uno Tidbit: <Topic>` | 600–1,200 words | series welcome → focused how-to → Conclusion. Self-aware about brevity: "This is supposed to be a small tidbit, after all!" |
| Conference recap | `<Event> Recap` | 1,300–1,800 words | attendance context → booth/workshop/talk sections → networking & people (named, with social links) → travel/food/fun → Conclusion |
| Deep dive / general | descriptive, sometimes playful parenthetical: "Introducing Uno Chefs (and some other stuff)" | 1,000–1,750 words | context + links → The Problem / concept → code walkthrough with diffs → Next Steps or Conclusion |

## 3. Mechanical conventions (hard rules)

- **Filename:** `YYYY-MM-DD-slug.md` in `docs/_posts/` (drafts, undated, in `docs/_drafts/`).
- **Front matter, exactly this shape** (title usually double-quoted):

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

  - `category` is one of exactly: `toolkit-tuesday`, `uno-tidbit`, `conference`, `uno-general`. A new category requires explicit human sign-off.
  - Never add `layout`, `date`, `author`, `toc`, `read_time`, etc. — those come from `_config.yml` defaults.
  - Tags: lowercase kebab-case array; Uno posts include platform tags like `uno-platform`, `uno`, `unoplatform`. (One historical exception: `Agents, AI, MCP` capitalized — treat lowercase as the rule.)
  - Images live in a per-post folder: `assets/images/<post-slug>/`.
- **Links are reference-style:** `[Uno Toolkit][uno-toolkit]` in prose with `[id]: url` definitions at the bottom of the file, and `{% include links.md %}` as the final line when shared links are used (14 of 21 posts). Inline `[text](url)` links appear only 5 times across the entire corpus — allow at most one as a rare exception, never as the pattern. Bare URLs: never.
- **Emoji are GitHub shortcodes, never Unicode:** `:wave:`, `:wink:`, `:heart_eyes:`, `:crossed_fingers:`, `:sweat_smile:`... Density: roughly 1–3 per post (a burst is fine in a joke), used as punchlines and in the sign-off. Never in headings (one historical exception in a joke H4 caption), never as bullet decoration.
- **Punctuation fingerprint — ZERO em-dashes.** The corpus contains not a single `—`. He uses commas, parentheses, and periods instead. **Any em-dash is an automatic violation.** Semicolons are near-absent in prose. `?!?`, `...`, and exclamation points are in-voice.
- **Code:** fenced blocks always tagged (`xml`, `csharp`, `bash`, `diff`); `diff` blocks for before/after agent or refactor comparisons; every API/type/property/control name backticked in prose (`NavigationBar`, `MainCommandMode`, `IState<string>`); omission marked with comments like `// Code omitted for brevity` or `<!-- Some code has been omitted for brevity -->`.
- **Notices:** Minimal Mistakes kramdown classes appended after the paragraph: `{: .notice--info}`, `{: .notice--warning}` (occasionally `--primary`). Used for platform caveats and version warnings, roughly 0–2 per post.
- **Media:** `{% include video id="..." provider="youtube" %}` or `provider="google-drive"`; simple screenshots as `![alt](/assets/images/...)` with an italic caption line beneath (`*Me giving my talk...*`); GIFs for interaction demos; side-by-side phone screenshots via `![..](..)|![..](..)`.

## 4. Phrases that ARE his voice (verified in corpus — do not flag)

"Catch you in the next one :wave:" · "Let's dive in" / "Let's dive into" / "jump into some code" · "In this article" (4 uses) · "Whether you..." constructions (8 uses) · "seamless" (3 uses) · "First thing's first" · "the crown jewel" · "bells and whistles" · "boatload" · "Let's see it in action" · "the last pieces of the puzzle" · "Putting it all together" · "under the hood" · "It's important to note here that..." (sparingly) · "Stay tuned"

## 5. Blacklist — words/phrases with ZERO occurrences in the corpus

Presence of any of these is a violation; two or more distinct hits is an automatic CHANGES_REQUESTED on its own:

- any em-dash `—` (automatic fail even once)
- "delve" / "delving"
- "In conclusion," (as prose)
- "Furthermore" / "Moreover"
- "leverage" (as a verb)
- "crucial"
- "game-changer" / "game-changing"
- "ever-evolving" / "the ... landscape"
- "unlock" / "elevate" / "supercharge" / "empower"
- "excited to share" / "thrilled to announce"
- "without further ado" / "buckle up"
- "Happy coding!" (as a sign-off)

## 6. Structural AI tells (flag on pattern, not single words)

- Uniform paragraph and sentence lengths; every section 2–3 tidy paragraphs.
- Triad stacking: "fast, flexible, and reliable" style adjective/noun triples recurring.
- A summary sentence dutifully closing every section.
- Hedging density: more than one "It's worth noting / It's important to note / Additionally," per post (each appears at most once in the entire corpus).
- Bold-for-emphasis sprinkled through prose instead of ALL CAPS.
- Bullet lists replacing narrative in sections that the corpus writes as prose (recaps, opinions, walkthrough commentary). His bullets appear for feature enumerations, Further Reading, and code observations.
- Perfectly balanced "On one hand / On the other hand" constructions.
- Generic audience flattery ("As developers, we all know...") and hype intros ("In today's fast-paced world of cross-platform development...").
- Zero jokes, zero self-deprecation, zero personal asides in a 1,000+ word post. Steve is incapable of that.
