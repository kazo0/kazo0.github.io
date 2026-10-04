---
title: "Semantic Design in Uno Themes - Part 2"
category: uno-general
header:
  teaser: /assets/images/simple-design-semantic-tokens/hero.jpg
  og_image: /assets/images/simple-design-semantic-tokens/hero.jpg
tags: [uno-themes, uno-themes-8, simple, semantic-tokens, design-tokens, theming, material, uno-platform, uno, unoplatform]
---

In [Part 1]({% post_url 2026-10-01-simple-design-semantic-tokens %}) of this little series I dug into the Semantic Design Language in `Uno Themes`: semantic styles that let your XAML ask for a ROLE like `FilledButtonStyle` instead of a design-system-specific key, and the Semantic Design Tokens for spacing, shape, and sizing that sit underneath them. All of that ships in Uno Themes 7.x today.

This time I want to look ahead. The upcoming 8.0 release builds on that same foundation and makes it a whole lot more flexible. The token knobs from Part 1 finally reach your controls at runtime, and two new ones join the family, one for spacing and one for fonts. The seed color generator that already ships in 7.x gets some love too, so your colors stay true to your brand and repaint live. This is the fun part.

**Preview:** This post explores the upcoming Uno Themes 8.0 release and its development documentation. The 8.0 packages haven't been released yet, so some APIs and behavior shown here may change before release. Links point to the [public Uno Themes docs][themes-overview-docs], which may lag behind this preview.
{: .notice--info}

As in Part 1, everything you'll see comes from [ThemeStudio][theme-studio], my little demo app for flipping design systems, seed colors, and tokens live. I'll keep saying "the 8.0 branch" below. That's the [`servicing/8.0`][themes-8-branch] branch of the Uno Themes repo, and it's what the code and behavior in this post are based on. Let's dive in.

## Turning Those Knobs at Runtime

In Part 1 we met the [scalar theme properties]({% post_url 2026-10-01-simple-design-semantic-tokens %}#turning-the-big-knobs) that regenerate a whole token scale from a single value in `App.xaml`. In 7.x that's `DefaultCornerRadius` and `DefaultDensity`, where the density preset doubles as the base spacing unit: `Compact`, `Regular`, and `Comfy` mean 3, 4, and 5.

The 8.0 branch splits those two ideas apart with a new `DefaultSpacing` knob. It owns the base spacing unit, and `DefaultDensity` becomes a pure mode that scales it (×0.75, ×1, and ×1.25), so the two compose:

```xml
<!-- A 6px brand unit in Compact mode: Space100 is 6 × 0.75 = 4.5 -->
<SimpleTheme xmlns="using:Uno.Simple" DefaultSpacing="6" DefaultDensity="Compact" />
```

With the default base of 4 you still get the familiar 3, 4, and 5. All of these knobs now work at runtime too, which is the compact-mode toggle you've been hand-rolling, reduced to one property. More on what "at runtime" means in a second.

The other new knob is one I've wanted for a while: a single root for typography. In the 8.0 branch, `DefaultFontFamily` is the root for the whole semantic type scale, so swapping the font the design system uses is one property instead of the `TypefacePlain` and `TypefaceBrand` pair from 7.1:

```xml
<SimpleTheme xmlns="using:Uno.Simple" DefaultFontFamily="ms-appx:///Fonts/MyFont.ttf#MyFont" />
```

Point it at a variable font, or one shipping a font manifest, so the per-scale `*FontWeight` tokens still render the way the type scale intends. Font overrides take precedence over the generated family keys.

One thing to watch: this only applies to text styled by the design system. A plain, unstyled `TextBlock` still uses the framework's default font, and `DefaultFontFamily` won't touch that. The [typography guide][design-tokens-docs] covers both the property and the `FontOverrideSource` route.

So what actually happens the moment you assign one of these at runtime? In 7.x the tokens regenerated, but no control ever saw it, because the control styles read them through `StaticResource`, which snapshots the value when the style is parsed.

{% include local-video.html
     src="/assets/images/uno-themes-8-runtime-seed-colors/font-runtime.mp4"
     poster="/assets/images/uno-themes-8-runtime-seed-colors/font-runtime-poster.png"
     caption="Switching the Typeface in the design panel from Simple's default Inter to Roboto, then to Fraunces. ThemeStudio sets DefaultFontFamily, then runs a theme-change pass so everything on screen picks up the new font." %}

8.0 flips that. The styles now read the tokens through `ThemeResource`, so a theme-change pass re-resolves everything in place. Toggle the root's `RequestedTheme` away from its `ActualTheme` and back, or just recreate the root content. Controls already on screen keep the values they resolved at load time until you do, since these are plain `Thickness`, `CornerRadius`, and `FontFamily` values rather than live brushes. Colors, as you're about to see, work a little differently.

## Semantic Color From a Single Seed

The last piece, and honestly the flashiest, is color. For the longest time, theming an app meant defining 30-plus color resources across Light and Dark. That's a lot of hex codes to keep in sync, and I have absolutely shipped a Dark theme with one stubbornly-wrong shade because I fat-fingered a copy-paste somewhere. :sweat_smile:

This one isn't actually new. Seed color generation shipped back in 7.0, so here's a quick refresher before we get to what 8.0 changes. It uses the Material Design 3 HCT (Hue-Chroma-Tone) color model to build Light and Dark palettes from a `PrimarySeed` on the theme's `Colors` property, a `ThemeColors` object. It supplies primary, secondary, tertiary, surface, and outline roles. The four `Error*` colors are excluded from generation and keep their base-palette values unless you explicitly override them:

```xml
<SimpleTheme xmlns="using:Uno.Simple">
    <SimpleTheme.Colors>
        <ThemeColors xmlns="using:Uno.Themes"
                     PrimarySeed="#6750A4" />
    </SimpleTheme.Colors>
</SimpleTheme>
```

The palette uses the same semantic color roles under either theme. Remember Simple's default grayscale from Part 1? That one seed is all it takes to turn it into a full palette. Secondary and Tertiary get auto-derived from the primary, but you can always pin them explicitly if you want more control.

What 8.0 changes is WHAT comes out of the generator. In 7.x, Material boosted every seed to the tonal-spot recipe's minimum chroma, while Simple kept the seed's chroma. Either way, the Light `PrimaryColor` was a derived tone rather than the color you actually picked.

The 8.0 branch puts both themes on a new default `SeedColorMode` called `Fidelity`. In Light mode, the generated `PrimaryColor` keeps the seed's RGB value, with alpha treated as fully opaque, and the generator chooses `OnPrimaryColor` to give that pair at least 4.5:1 contrast. Supporting palettes follow the seed's chroma, so a muted seed produces a muted palette and a gray seed stays neutral. In Dark mode, `PrimaryColor` uses a lighter tone derived from the seed instead of the exact input color.

If you'd rather keep the Material tonal-spot recipe, set `SeedColorMode="TonalSpot"` on the same `ThemeColors` object. That recipe applies minimum chroma rather than preserving the seed's exact Light primary. It does NOT reproduce 7.x colors exactly: the 8.0 branch also contains a color-math fix for washed-out saturated seeds.

Explicit color overrides still win, same as in 7.x. Values in `ThemeColors.OverrideDictionary` or the dictionary loaded through `OverrideSource` beat the generated colors, which in turn beat the theme's built-in palette. Just remember that the contrast guarantee above is about the generated primary pair. The moment you replace either color yourself, that pairing is on you.

The other big change is runtime updates. `SemanticThemeHelper` has let you swap the seed from code since 7.x, but every change built fresh brush instances, so whatever was already on screen held onto the old colors until you recreated the root content. In 8.0 the semantic brushes are long-lived instances whose colors get rewritten in place, so controls using those brushes repaint on the spot. No re-navigation, no theme toggle, and that includes the hover and pressed variants. A brush you explicitly override still takes precedence. With a theme already merged into `Application.Current.Resources`, it's still a one-liner:

```csharp
using Uno.Themes;
using Windows.UI;

// Rebrand the whole app on the fly
SemanticThemeHelper.PrimarySeed = Colors.Green;

// Restore the built-in palette, retaining any explicit color overrides
SemanticThemeHelper.PrimarySeed = null;
```

{% include local-video.html
     src="/assets/images/uno-themes-8-runtime-seed-colors/seed-runtime.mp4"
     poster="/assets/images/uno-themes-8-runtime-seed-colors/seed-runtime-poster.png"
     caption="Starting from Simple's default grayscale, enabling seed colors, then dragging around the color wheel in the design panel. Controls using the generated semantic brushes update without navigation." %}

Picture a "pick your accent color" setting in your app, wired to one property. That's the part I like most about this API.

One gotcha: the helper's properties throw if no theme is merged into the application's resources yet, so `SemanticThemeHelper.GetTheme()` is the safe check when you're not sure. It returns `null` instead of throwing.

## Preparing for 8.0

Seed generation is still opt-in, just like 7.x. An app that never sets `PrimarySeed` keeps its built-in color palette, so you're safe there. It's the other style and font customizations that deserve a closer look. Here are the changes I'd start preparing for now, and definitely circle back to the [migration guide][migration-docs] once the packages actually ship:

- **Seeded colors:** expect different output when moving from 7.x to the upcoming release. For Material apps, `TonalSpot` keeps the previous recipe, but the color-math fix still applies. Simple already preserved the seed's chroma in 7.x, but its Light primary is now your exact seed.
- **Runtime seed changes:** if you recreate your root content after changing a seed, you can drop that workaround. And if your code caches a brush's `Color` or expects a fresh brush instance after each change, hold onto the resource key instead.
- **Density:** `Density` values no longer double as the base spacing unit. If you relied on `Compact` meaning 3, set `DefaultSpacing` for the base and let `DefaultDensity` scale it.
- **Root fonts:** plan to replace `TypefacePlain` and `TypefaceBrand` overrides with `DefaultFontFamily`. The 8.0 branch also removes Simple's `SimpleFontFamily` and its old per-weight family keys, so lean on the root family and the relevant `*FontWeight` tokens instead.
- **Material fonts:** in the 8.0 branch, overriding `MaterialRegularFontFamily`, `MaterialMediumFontFamily`, or `MaterialLightFontFamily` no longer changes Material v2 typography. Those keys remain for compatibility, and the v1 styles are unchanged. Move v2 font customization to the new root or specific scale keys.
- **Custom theme subclasses:** the 8.0 branch marks `UseHighFidelityColors` obsolete in favor of `ThemeColors.SeedColorMode`. Your existing overrides still work unless you set an explicit mode on `Colors`.

And if you're coming from an even earlier version, give the guide's v7 section a read too for the other style and API changes.

## Conclusion

The shared vocabulary from Part 1 isn't going anywhere. What 8.0 adds is more control behind it, and fewer reasons to hand-roll your own theming code. You still write `FilledButtonStyle` and `Space400` to describe what you want, you just finally get to turn the knobs behind them without touching your markup.

I'm genuinely looking forward to getting these refinements into a proper release. In the meantime, poke around [ThemeStudio][theme-studio] and the [`servicing/8.0`][themes-8-branch] branch, and let me know what you build with it.

Hope you learned something and I'll catch you in the next one :wave:

## Further Reading

- [Semantic Design in Uno Themes - Part 1]({% post_url 2026-10-01-simple-design-semantic-tokens %})
- [Uno Themes Overview][themes-overview-docs]
- [Semantic Design Tokens][design-tokens-docs]
- [Seed Color Palette Generation][seed-colors-docs]
- [Upgrading to Uno Themes v8][migration-docs]
- [Uno Themes 8.0 branch][themes-8-branch]
- [ThemeStudio on GitHub][theme-studio]

[themes-8-branch]: https://github.com/unoplatform/Uno.Themes/tree/servicing/8.0
[themes-overview-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/themes-overview.html
[design-tokens-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/design-tokens.html
[seed-colors-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/seed-colors.html
[migration-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/material-migration.html#upgrading-to-uno-themes-v8
[theme-studio]: https://github.com/kazo0/ThemeStudio
{% include links.md %}
