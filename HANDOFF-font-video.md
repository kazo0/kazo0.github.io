# Handoff: DefaultFontFamily runtime video for Part 2

Record a short screen video of ThemeStudio changing its `DefaultFontFamily` live, then add it to the Part 2 blog post.

## Setup

- Repo: `~/src/ThemeStudio`, branch `feat/fraunces-typeface`. Commit `bc75da9` adds Fraunces as a fourth option in the design panel's Typeface picker. Don't push.
- Run it:

  ```shell
  cd ~/src/ThemeStudio && dotnet run --project ThemeStudio.csproj -f net10.0-desktop
  ```

- Resize the window so its content area is 1480x1008, to match the existing clip at `docs/assets/images/uno-themes-8-runtime-seed-colors/seed-runtime.mp4`. Use `seed-runtime-poster.png` next to it as the framing reference.
- Stay on Overview, Simple, Light, with seed colors off (the app's defaults). The design panel is on the right. Scroll the panel so TYPOGRAPHY > Typeface is visible while the headline "Make room for your next big idea." stays in view.
- Before recording, select Fraunces once and confirm the serif actually renders in the headline, cards, and buttons. If it doesn't, stop and report back. Don't record a broken state.

## Record

Aim for about 12–18 seconds, with the cursor visible:

1. Hold about 1.5 s on "Theme default" (Inter).
2. Open the Typeface dropdown, pick Roboto, then hold about 2 s.
3. Open it again, pick Fraunces, then hold about 3 s. This is the money shot.
4. Optionally go back to Theme default and hold about 1 s.

Move the cursor deliberately, with no hunting. Record only the app window (for example `screencapture -v -l<windowid>`, or a region capture), not the whole desktop.

## Encode

Follow `AGENTS.md`: MP4, not GIF, kept small.

```shell
ffmpeg -i raw.mov -vf "scale=1480:-2:flags=lanczos,fps=24" -c:v libx264 -crf 23 \
  -preset slow -pix_fmt yuv420p -movflags +faststart -an \
  docs/assets/images/uno-themes-8-runtime-seed-colors/font-runtime.mp4
```

- Poster: grab a frame with Fraunces applied and save it as `font-runtime-poster.png` in the same folder, as a PNG with no alpha channel.
- Keep the MP4 under 1 MB (the seed clip is 755 KB).

## Embed

In `docs/_posts/2026-10-04-uno-themes-8-runtime-seed-colors.md` (branch `post/uno-themes-8-runtime-seed-colors`), add this right after the paragraph that starts "So what actually happens the moment you assign one of these at runtime?", at the end of the "Turning Those Knobs at Runtime" section:

```liquid
{% include local-video.html
     src="/assets/images/uno-themes-8-runtime-seed-colors/font-runtime.mp4"
     poster="/assets/images/uno-themes-8-runtime-seed-colors/font-runtime-poster.png"
     caption="Switching the Typeface in the design panel from Simple's default Inter to Roboto, then to Fraunces. ThemeStudio sets DefaultFontFamily, then runs a theme-change pass so everything on screen picks up the new font." %}
```

The caption is accurate: ThemeStudio's `MainPage.OnTokensChanged` calls `ThemeController.Refresh`, which flips `RequestedTheme` away and back.

## Finish

1. Run `npm run lint:md` from the repo root.
2. Look at a few frames of the encoded video to check it.
3. Commit with a Conventional Commit, for example `docs(post): add DefaultFontFamily runtime video to part 2`. Leave this handoff file out of the commit.
4. Don't push. The user reviews first.
