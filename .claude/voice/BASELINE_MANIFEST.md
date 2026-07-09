# Voice Baseline Manifest

**FROZEN: 2026-07-09** | **Baseline commit: `69c856acfb802ec0dfe73181ccd0a9f24389a5b9`** (`master` HEAD as of the freeze date)

This manifest records the complete set of blog posts written by Steve Bilogan *before* AI-assisted content generation began on this blog. These 21 posts are the **only** valid ground truth for voice, style, syntax, and tone.

## Rules

1. **This list never grows.** Posts merged after the baseline commit are NOT voice references, even once they live in `docs/_posts/` on `master`. They are the output being policed, not the standard.
2. **The pinned SHA never advances.** CI materializes the corpus by checking out `docs/_posts/` at the baseline commit into `.voice-baseline/`. Any PR that changes `VOICE_BASELINE_SHA` in the workflow is a reviewer-integrity violation.
3. **Corpus beats profile.** If `VOICE_PROFILE.md` ever disagrees with what these posts actually do, the posts win.

## The Frozen Corpus (21 posts, ~27,250 words)

| File | Title | Type | Words |
| --- | --- | --- | --- |
| `2023-11-10-hello-world.md` | Hello World! | general | 34 |
| `2023-11-14-techbash-recap.md` | TechBash Recap | conference | 1,299 |
| `2023-11-20-off-to-prague.md` | Update Conference: Off To Prague! | conference | 432 |
| `2023-11-21-toolkit-tuesday-navigationbar.md` | Toolkit Tuesdays: NavigationBar | toolkit-tuesday | 1,416 |
| `2023-11-28-toolkit-tuesday-tabbar.md` | Toolkit Tuesdays: TabBar | toolkit-tuesday | 1,090 |
| `2023-11-29-update-conf-recap.md` | Update Conference Recap | conference | 1,483 |
| `2023-12-05-toolkit-tuesday-statusbar.md` | Toolkit Tuesdays: StatusBar | toolkit-tuesday | 1,032 |
| `2023-12-19-toolkit-tuesday-safearea.md` | Toolkit Tuesdays: SafeArea | toolkit-tuesday | 1,715 |
| `2024-01-30-toolkit-tuesday-responsive.md` | Toolkit Tuesdays: Responsive | toolkit-tuesday | 1,484 |
| `2024-02-13-toolkit-tuesday-drawerflyout.md` | Toolkit Tuesdays: DrawerFlyoutPresenter | toolkit-tuesday | 2,243 |
| `2024-03-12-toolkit-tuesday-extendedsplashscreen.md` | Toolkit Tuesdays: ExtendedSplashScreen | toolkit-tuesday | 1,831 |
| `2024-03-28-tidbit-back-button.md` | Uno Tidbit: Handling the System Back Button | uno-tidbit | 614 |
| `2024-04-21-tidbit-resource-extension.md` | Uno Tidbit: Extending Your Resources | uno-tidbit | 597 |
| `2024-09-04-cph-devfest-recap.md` | NDC Copenhagen DevFest 2024 Recap | conference | 1,630 |
| `2024-09-05-tidbit-carousel.md` | Uno Tidbit: Building a Carousel Experience | uno-tidbit | 1,153 |
| `2024-11-02-packaging.md` | Packaging an Uno Platform app | uno-general | 1,054 |
| `2025-01-19-codemash-recap.md` | CodeMash 2025 Recap | conference | 1,561 |
| `2025-03-29-summit-recap.md` | MVP Summit 2025 Recap | conference | 1,809 |
| `2025-05-25-chefs-intro.md` | Introducing Uno Chefs (and some other stuff) | uno-general | 1,440 |
| `2025-07-02-chefs-login.md` | Uno Chefs Walkthrough - Login Page | uno-general | 1,609 |
| `2026-02-23-agent-skills-intro.md` | Agent Skills + Uno Platform | uno-general | 1,731 |

## Supporting baseline files

Also authoritative at the baseline commit:

- `docs/_includes/links.md` — the shared reference-link definitions
- `CLAUDE.md` — repo conventions (front matter defaults, embeds, notices)
