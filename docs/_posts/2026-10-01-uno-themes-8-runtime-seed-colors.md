---
title: "Semantic Design in Uno.Themes - Part 2"
category: uno-general
header:
  teaser: /assets/images/uno-themes-8-runtime-seed-colors/hero.jpg
  og_image: /assets/images/uno-themes-8-runtime-seed-colors/hero.jpg
tags: [uno-themes, uno-themes-8, simple, semantic-tokens, design-tokens, theming, material, uno-platform, uno, unoplatform]
---

In Part 1 of this little series I dug into the Semantic Design Language in `Uno.Themes`: semantic styles that let your XAML ask for a ROLE like `FilledButtonStyle` instead of a design-system-specific key, and the Semantic Design Tokens for spacing, shape, and sizing that sit underneath them. All of that ships in Uno.Themes 7.x today.

This time I want to look ahead. The upcoming 8.0 release builds on that same foundation and makes it a whole lot more flexible. We'll reshape an entire app's spacing and corners from a couple of properties, pull typography under a single root font, and generate a full color palette from one seed color. This is the fun part.

**Preview:** This post explores the upcoming Uno.Themes 8.0 release and its development documentation. The 8.0 packages haven't been released yet, so some APIs and behavior shown here may change before release. Links point to the [public Uno.Themes docs][themes-overview-docs], which may lag behind this preview.
{: .notice--info}

As in Part 1, everything you'll see comes from [ThemeStudio][theme-studio], my little demo app for flipping design systems, seed colors, and tokens live. Let's dive in.

## Trying the Preview

If you want something runnable, start with [this ThemeStudio snapshot][theme-studio-snapshot]. It pins `Uno.Material.WinUI` and `Uno.Simple.WinUI` to `9.0.0-dev.2`, with `Uno.Themes.WinUI` resolving transitively to the same version. Those are development packages, not an 8.0 release. The color-wheel video later in this post uses that build with the picker's `ColorSpectrumShape` set to `Ring`, and the API descriptions throughout are checked against `servicing/8.0`. If you want to test the exact branch implementation, build the libraries from that branch and drop those builds into your app.

If you need the Simple setup itself (the `UnoFeatures` entry and the `App.xaml` merge), Part 1 walks through it. Just keep in mind that adding Simple on its own won't opt you into any of the unreleased functionality below. That needs the development packages or your own branch builds.

## Turning the Big Knobs

Overriding the individual Semantic Design Tokens from Part 1 is great for surgical tweaks, but the tokens also roll up into a few scalar properties on the theme itself. In the current 8.0 implementation, Material and Simple expose the same knobs, so you can reshape an entire app from `App.xaml` using either theme.

`DefaultCornerRadius` and `DefaultSpacing` each generate a full scale from a single base value:

```xml
<!-- Base radius 2, base spacing 6 at the default Regular density -->
<MaterialTheme xmlns="using:Uno.Material" DefaultCornerRadius="2" DefaultSpacing="6" />
```

`Radius200` is now 4 and `Space200` is 12, and the corresponding `CornerRadius` and `Thickness` resources get generated too. `RadiusFull` stays 9999. Two attributes, and the whole app's proportions shift.

And my personal favorite, `DefaultDensity`, which dials the padding across your whole app between three presets. Density is a MODE, not a value: it multiplies the `DefaultSpacing` base unit, so a branded spacing unit and a density preset compose instead of fighting:

```xml
<!-- Tighten everything up for a data-dense screen -->
<SimpleTheme xmlns="using:Uno.Simple" DefaultDensity="Compact" />

<!-- Or a 6px brand unit in comfortable mode (effective base 7.5) -->
<SimpleTheme xmlns="using:Uno.Simple" DefaultSpacing="6" DefaultDensity="Comfy" />
```

| `DefaultDensity` | Factor | Base at default spacing (4) | Feel |
| --- | :---: | :---: | --- |
| `Compact` | ×0.75 | 3 | Tighter padding for data-dense UIs |
| `Regular` (default) | ×1 | 4 | Balanced spacing |
| `Comfy` | ×1.25 | 5 | More generous padding |

<figure>
    <a href="/assets/images/uno-themes-8-runtime-seed-colors/density.png" class="image-popup"><img class="align-center" src="/assets/images/uno-themes-8-runtime-seed-colors/density.png" alt="The same Simple settings screen at Compact, Regular, and Comfy density, showing progressively more generous padding inside cards and inputs while control heights stay the same"/></a>
</figure>

The `Space*` resources change here, while `ControlHeight*`, `IconSize*`, and `TouchTargetMinSize` hold their fixed values. Padding and margins that pull from the spacing resources follow the new scale, and anything you hard-coded doesn't budge. Layout still depends on your content and constraints, so this isn't a promise that every control ends up exactly the same height.

The release also brings typography under a single root. In the 8.0 branch, `DefaultFontFamily` is the root for the semantic type scale, so changing the font used by the design system is one property:

```xml
<SimpleTheme xmlns="using:Uno.Simple" DefaultFontFamily="ms-appx:///Fonts/MyFont.ttf#MyFont" />
```

Point it at a variable font, or one shipping a font manifest, so the per-scale `*FontWeight` tokens still render the way the type scale intends. Font overrides take precedence over the generated family keys.

One thing to watch: this only applies to text styled by the design system. A plain, unstyled `TextBlock` still uses the framework's default font, and `DefaultFontFamily` won't touch that. The [typography guide][design-tokens-docs] covers both the property and the `FontOverrideSource` route.

In the 8.0 branch, all four of these knobs are runtime-settable. Assign one and the tokens regenerate, so anything created afterwards picks up the new scale. Controls already on screen keep the values they resolved at load time, since these are plain `Thickness`, `CornerRadius`, and `FontFamily` values rather than live brushes. Their styles read the tokens through `ThemeResource` though, so a theme-change pass (toggle the root's `RequestedTheme` away from its `ActualTheme` and back, or just recreate the root content) re-resolves everything in place. Colors, as you're about to see, work a little differently.

## Semantic Color From a Single Seed

The last piece, and honestly the flashiest, is color. For the longest time, theming an app meant defining 30-plus color resources across Light and Dark. That's a lot of hex codes to keep in sync, and I have absolutely shipped a Dark theme with one stubbornly-wrong shade because I fat-fingered a copy-paste somewhere. :sweat_smile:

Seed color generation uses the Material Design 3 HCT (Hue-Chroma-Tone) color model to build Light and Dark palettes from a `PrimarySeed` on `ThemeColors`. It supplies primary, secondary, tertiary, surface, and outline roles. The four `Error*` colors are excluded from generation and keep their base-palette values unless you explicitly override them:

```xml
<us:SimpleTheme xmlns:us="using:Uno.Simple">
    <us:SimpleTheme.Colors>
        <ut:ThemeColors xmlns:ut="using:Uno.Themes"
                        PrimarySeed="#6750A4" />
    </us:SimpleTheme.Colors>
</us:SimpleTheme>
```

The palette uses the same semantic color roles under either theme. Remember Simple's default grayscale from Part 1? That one seed is all it takes to turn it into a full palette. Secondary and Tertiary get auto-derived from the primary, but you can always pin them explicitly if you want more control.

8.0 will also change WHAT comes out of the generator. In the current implementation, the default `SeedColorMode` is `Fidelity`: in Light mode, the generated `PrimaryColor` keeps the seed's RGB value, with alpha treated as fully opaque. The generator chooses `OnPrimaryColor` to give that pair at least 4.5:1 contrast. Supporting palettes follow the seed's chroma, so a muted seed produces a muted palette and a gray seed stays neutral. In Dark mode, `PrimaryColor` uses a lighter tone derived from the seed instead of the exact input color.

If you'd rather use the Material tonal-spot recipe, set `SeedColorMode="TonalSpot"` on the same `ThemeColors` object. That recipe applies minimum chroma rather than preserving the seed's exact Light primary. It does NOT reproduce 7.x colors exactly: the 8.0 branch also contains a color-math fix for washed-out saturated seeds.

Explicit color overrides still win, as you'd hope. Values in `ThemeColors.OverrideDictionary` or the dictionary loaded through `OverrideSource` beat the generated colors, which in turn beat the theme's built-in palette. Just remember that the contrast guarantee above is about the generated primary pair. The moment you replace either color yourself, that pairing is on you.

The 8.0 implementation also does something nice with runtime updates. The semantic brushes are long-lived instances whose colors get rewritten in place, so controls using those brushes repaint on the spot. No re-navigation, no theme toggle, and that includes the hover and pressed variants. A brush you explicitly override still takes precedence. With a theme already merged into `Application.Current.Resources`, the helper makes this a one-liner:

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

In the current 8.0 branch, seed generation stays opt-in. An app that never sets `PrimarySeed` keeps its built-in color palette, so you're safe there. It's the other style and font customizations that deserve a closer look. Here are the changes I'd start preparing for now, and definitely circle back to the [migration guide][migration-docs] once the packages actually ship:

- **Seeded colors:** expect different output when moving from 7.x to the upcoming release. `TonalSpot` keeps the previous recipe, but the color-math fix still applies.
- **Root fonts:** plan to replace `TypefacePlain` and `TypefaceBrand` overrides with `DefaultFontFamily`. The 8.0 branch also removes Simple's `SimpleFontFamily` and its old per-weight family keys, so lean on the root family and the relevant `*FontWeight` tokens instead.
- **Material fonts:** in the 8.0 branch, overriding `MaterialRegularFontFamily`, `MaterialMediumFontFamily`, or `MaterialLightFontFamily` no longer changes Material v2 typography. Those keys remain for compatibility, and the v1 styles are unchanged. Move v2 font customization to the new root or specific scale keys.
- **Custom theme subclasses:** the 8.0 branch marks `UseHighFidelityColors` obsolete in favor of `ThemeColors.SeedColorMode`. Your existing overrides still work unless you set an explicit mode on `Colors`.

And if you're coming from an even earlier version, give the guide's v7 section a read too for the other style and API changes.

## Conclusion

That shared vocabulary from Part 1 hasn't changed one bit. What 8.0 adds is the big dials behind it: fonts, tokens, and a whole color palette, all adjustable live. You still write `FilledButtonStyle` and `Space400` to describe what you want, you just finally get to turn the knobs behind them without touching your markup.

I'm genuinely looking forward to getting these refinements into a proper release. In the meantime, go try the development demo, poke around the branch, and let me know what you build with it.

Hope you learned something and I'll catch you in the next one :wave:

## Further Reading

- [Uno.Themes Overview][themes-overview-docs]
- [Semantic Design Tokens][design-tokens-docs]
- [Seed Color Palette Generation][seed-colors-docs]
- [Upgrading to Uno Themes v8][migration-docs]
- [ThemeStudio on GitHub][theme-studio]

[themes-overview-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/themes-overview.html
[design-tokens-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/design-tokens.html
[seed-colors-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/seed-colors.html
[migration-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/material-migration.html#upgrading-to-uno-themes-v8
[theme-studio-snapshot]: https://github.com/kazo0/ThemeStudio/tree/18687f1448b6138d23ccd972ccef9128913959da
[theme-studio]: https://github.com/kazo0/ThemeStudio
{% include links.md %}
