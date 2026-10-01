---
title: "A Look Ahead at Uno.Themes 8.0: Semantic Styles, Tokens, and Colors"
category: uno-general
header:
  teaser: /assets/images/simple-design-semantic-tokens/hero.jpg
  og_image: /assets/images/simple-design-semantic-tokens/hero.jpg
tags: [uno-themes, simple, semantic-tokens, design-tokens, theming, material, uno-platform, uno, unoplatform]
---

A little while back I wrote about [hosting three Uno apps inside a single Uno app]({% post_url 2026-08-11-alc-super-themes-app %}) so you could flip between Material, Cupertino, and Simple live. That demo gets at something I've been meaning to dig into: the [Semantic Design Language][semantic-styles-docs] in `Uno.Themes`. How do you describe the styles, spacing, typography, and colors your UI needs without tying every choice to one design system?

The Semantic Design Language gives your XAML a shared vocabulary, with semantic styles to describe controls and [Semantic Design Tokens][design-tokens-docs] to define the values they use. Uno.Themes 7.0 introduced that shared layer alongside Simple. The upcoming 8.0 release builds on that foundation with a single root typeface, runtime updates to the shared tokens, and seed colors that preserve your chosen color in the Light palette. Material and Simple use the same vocabulary, so you can customize either without scattering design-system-specific choices through your markup.

**Preview:** This post explores the upcoming Uno.Themes 8.0 release and its development documentation. The 8.0 packages haven't been released yet, so some APIs and behavior shown here may change before release. Links point to the [public Uno.Themes docs][themes-overview-docs], which may lag behind this preview.
{: .notice--info}

We'll start with the shared vocabulary introduced in 7.x, then look at what the current 8.0 implementation adds on top. I'm focusing on Material and Simple here. Cupertino rides along on the same library, but that doesn't mean all three themes expose the exact same styles.

Let's dive in.

<a href="/assets/images/simple-design-semantic-tokens/simple-vs-material.png" class="image-popup"><img class="align-center" src="/assets/images/simple-design-semantic-tokens/simple-vs-material.png" alt="The same Forma overview screen rendered side by side under SimpleTheme, in its default grayscale palette, and MaterialTheme, in its default purple palette, with identical layout and content but different colors, control shapes, and typography"/></a>

Everything you'll see in this post comes from [ThemeStudio][theme-studio], a small demo app I put together that lets you flip design systems, seed colors, and tokens live. Same XAML in both halves of that screenshot, each theme wearing its out-of-the-box palette, and I promise I didn't touch a single style key between them.

## The Problem With Theme-Prefixed Styles

Here's the thing that's always bugged me a little about styling Uno apps. If you wanted a filled button under Material, you reached for `MaterialFilledButtonStyle`:

```xml
<Button Style="{StaticResource MaterialFilledButtonStyle}" Content="Save" />
```

That works great, right up until the day you want to try a different design system. Now every one of those `Material*` keys is wrong, and you're spelunking through your XAML swapping prefixes and praying you didn't miss one. Your markup is welded to a single design system, and there's no clean way to say "give me a filled button, whatever that means for the theme that's currently active."

That's exactly the problem the Semantic Design Language solves. Your XAML describes the *role* a style or resource plays, and the active theme fills in the design.

## Semantic Styles: One Key, Two Design Systems

Now for the good part. Instead of `MaterialFilledButtonStyle`, the semantic layer introduced in 7.x gives you a single unprefixed key:

```xml
<!-- Works under both Material and Simple. No edits required. -->
<Button Style="{StaticResource FilledButtonStyle}" Content="Save" />
```

That exact XAML renders a proper Material filled button under `MaterialTheme` and a proper Simple filled button under `SimpleTheme`. You don't change a thing.

The mechanism behind this is refreshingly boring, and I mean that as a compliment. Each theme's `_Resources.xaml` defines a `StaticResource` alias that points the semantic key at the theme's concrete style:

- Under Material, `FilledButtonStyle` resolves to `MaterialFilledButtonStyle`
- Under Simple, `FilledButtonStyle` resolves to `SimpleFilledButtonStyle`

Same idea across the board: `OutlinedTextBoxStyle`, `ContentDialogStyle`, `ComboBoxStyle`, the full Material Design 3 typography scale (`HeadlineLarge`, `BodyMedium`, `LabelSmall`, and friends), all of it. Write the semantic key, let the active theme sort out the details.

The two design systems don't have perfectly overlapping vocabularies. Simple does not define the `ElevatedButtonStyle`, `CommandBarStyle`, or `MediaTransportControlsStyle` aliases, so don't reference those keys expecting a Simple equivalent. The Floating Action Button aliases do exist, but map to Simple icon buttons rather than distinct FAB styles. Even a shared key can have a different interpretation: `OutlinedButtonStyle` maps to Simple's tonal button. Check the [semantic styles mapping table][semantic-styles-docs] when choosing the keys your app depends on.
{: .notice--warning}

## Semantic Design Tokens: The Shared Vocabulary

Semantic styles are the visible tip of the iceberg. Underneath is the other half of that shared foundation: Semantic Design Tokens. These are just XAML resources for spacing, shape, control sizing, and typography that the design systems' styles and templates consume. Override one and you move every control that references it. A value you hard-coded directly on a control stays exactly where you put it.

Spacing is a numeric scale. At the default spacing unit of 4 and `Regular` density, a few of the values look like this (in XAML layout units):

| Key | Default Value | Thickness Key |
| --- | --- | --- |
| `Space100` | 4 | `Space100Thickness` |
| `Space200` | 8 | `Space200Thickness` |
| `Space300` | 12 | `Space300Thickness` |
| `Space400` | 16 | `Space400Thickness` |
| `Space600` | 24 | `Space600Thickness` |

Shape works similarly, with a default corner-radius unit of 4. `RadiusFull` is the exception: it stays at 9999 for a pill shape, regardless of the base unit:

| Key | Default Value | CornerRadius Key |
| --- | --- | --- |
| `Radius100` | 4 | `Radius100CornerRadius` |
| `Radius200` | 8 | `Radius200CornerRadius` |
| `Radius400` | 16 | `Radius400CornerRadius` |
| `RadiusFull` | 9999 | `RadiusFullCornerRadius` |

And density covers control heights and icon sizes (`ControlHeightMedium`, `IconSizeMedium`, `TouchTargetMinSize`, and so on).

Want rounder corners for controls in a page that use `Radius200CornerRadius`? Override that resource in the page:

```xml
<Page.Resources>
    <CornerRadius x:Key="Radius200CornerRadius">10</CornerRadius>
</Page.Resources>
```

Any control that resolves `Radius200CornerRadius` in that scope picks up the override. Just know that it doesn't automatically change `Radius200` or any of the other corner-radius keys. Same goes for spacing: the numeric `Space200` and its `Space200Thickness` companion are separate resources. Override whichever form your style actually consumes, or reach for the theme properties below to regenerate the whole scale at once.

## Simple and Material: Two Takes on the Same Language

With that shared vocabulary in place, picking a design system is really just about how you want your app to look. Uno Simple implements Figma's Simple Design System (SDS). Where Material comes with strong Material Design opinions baked in, Simple ships a clean grayscale palette and gets out of your way. That makes it a lovely place to start when you want to bring your own brand rather than adopt someone else's, and a great way to see how far those shared tokens can take your own design.

### Trying the Preview

If you want something runnable, start with [this ThemeStudio snapshot][theme-studio-snapshot]. It pins `Uno.Material.WinUI` and `Uno.Simple.WinUI` to `9.0.0-dev.2`, with `Uno.Themes.WinUI` resolving transitively to the same version. Those are development packages, not an 8.0 release. The color-wheel video uses that build with the picker's `ColorSpectrumShape` set to `Ring`, and the API descriptions throughout this post are checked against `servicing/8.0`. If you want to test the exact branch implementation, build the libraries from that branch and drop those builds into your app.

The configuration below shows how to wire up Simple. Just keep in mind the later 8.0-specific examples assume you've actually got library builds with those APIs in hand.

Add `SimpleTheme` to your project's existing `UnoFeatures` list. A project using only that feature would have:

```xml
<UnoFeatures>SimpleTheme</UnoFeatures>
```

Then merge the theme into your `App.xaml`:

```xml
<Application.Resources>
    <ResourceDictionary>
        <ResourceDictionary.MergedDictionaries>
            <!-- other dictionaries omitted for brevity -->
            <us:SimpleTheme xmlns:us="using:Uno.Simple" />
        </ResourceDictionary.MergedDictionaries>
    </ResourceDictionary>
</Application.Resources>
```

If you're starting fresh, the template can create the Simple setup. You'll still need to select suitable development packages or source builds for the preview features:

```bash
dotnet new unoapp -o UnoSimpleApp -theme simple
```

Out of the box Simple is intentionally plain. No default seed color, just a neutral grayscale palette that stays grayscale until you give it something to work with. We'll give it something to work with shortly. :wink:

## Turning the Big Knobs

Overriding individual Semantic Design Tokens is great for surgical tweaks, but the tokens also roll up into a few scalar properties on the theme itself. In the current 8.0 implementation, Material and Simple expose the same knobs, so you can reshape an entire app from `App.xaml` using either theme.

`DefaultCornerRadius` and `DefaultSpacing` each generate a full scale from a single base value:

```xml
<!-- Base radius 2; base spacing 6 at the default Regular density -->
<MaterialTheme xmlns="using:Uno.Material" DefaultCornerRadius="2" DefaultSpacing="6" />
```

`Radius200` is now 4 and `Space200` is 12, and the corresponding `CornerRadius` and `Thickness` resources get generated too. `RadiusFull` stays 9999.

And my personal favorite, `DefaultDensity`, which dials the padding across your whole app between three presets. Density is a *mode*, not a value: it multiplies the `DefaultSpacing` base unit, so a branded spacing unit and a density preset compose instead of fighting:

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

<a href="/assets/images/simple-design-semantic-tokens/density.png" class="image-popup"><img class="align-center" src="/assets/images/simple-design-semantic-tokens/density.png" alt="The same Simple settings screen at Compact, Regular, and Comfy density, showing progressively more generous padding inside cards and inputs while control heights stay the same"/></a>

The `Space*` resources change here, while `ControlHeight*`, `IconSize*`, and `TouchTargetMinSize` hold their fixed values. Padding and margins that pull from the spacing resources follow the new scale, and anything you hard-coded doesn't budge. Keep in mind the final rendered layout still depends on your content and constraints, so don't read this as a promise that every control ends up pixel-identical in height.

The upcoming release also brings typography under a single root. In the 8.0 branch, `DefaultFontFamily` is the root for the semantic type scale, so changing the font used by the design system is one property:

```xml
<SimpleTheme xmlns="using:Uno.Simple" DefaultFontFamily="ms-appx:///Fonts/MyFont.ttf#MyFont" />
```

Point it at a variable font, or one shipping a font manifest, so the per-scale `*FontWeight` tokens still render the way the type scale intends. Font overrides take precedence over the generated family keys.

One thing to watch: this only applies to text styled by the design system. A plain, unstyled `TextBlock` still uses the framework's default font, and `DefaultFontFamily` won't touch that. The [typography guide][design-tokens-docs] covers both the property and the `FontOverrideSource` route.

In the 8.0 branch, all four of these knobs are runtime-settable. Assign one and the tokens regenerate, so anything created afterwards picks up the new scale. Controls already on screen keep the values they resolved at load time, since these are plain `Thickness`, `CornerRadius`, and `FontFamily` values rather than live brushes. Their styles read the tokens through `ThemeResource` though, so a theme-change pass (toggle the root's `RequestedTheme` away from its `ActualTheme` and back, or just recreate the root content) re-resolves everything in place. Colors, as you're about to see, work a little differently.
{: .notice--info}

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

The palette uses the same semantic color roles under either theme. In this Simple example, that one seed is all it takes to turn the default grayscale into a full palette. Secondary and Tertiary get auto-derived from the primary, but you can always pin them explicitly if you want more control.

8.0 will also change *what* comes out of the generator. In the current implementation, the default `SeedColorMode` is `Fidelity`: in Light mode, the generated `PrimaryColor` keeps the seed's RGB value, with alpha treated as fully opaque. The generator chooses `OnPrimaryColor` to give that pair at least 4.5:1 contrast. Supporting palettes follow the seed's chroma, so a muted seed produces a muted palette and a gray seed stays neutral. In Dark mode, `PrimaryColor` uses a lighter tone derived from the seed instead of the exact input color.

If you'd rather use the Material tonal-spot recipe, set `SeedColorMode="TonalSpot"` on the same `ThemeColors` object. That recipe applies minimum chroma rather than preserving the seed's exact Light primary. It does NOT reproduce 7.x colors exactly: the 8.0 branch also contains a color-math fix for washed-out saturated seeds.

Explicit color overrides still win, as you'd hope. Values in `ThemeColors.OverrideDictionary` or the dictionary loaded through `OverrideSource` beat the generated colors, which in turn beat the theme's built-in palette. Just remember that the contrast guarantee above is about the *generated* primary pair. The moment you replace either color yourself, that pairing is on you.

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
     src="/assets/images/simple-design-semantic-tokens/seed-runtime.mp4"
     poster="/assets/images/simple-design-semantic-tokens/seed-runtime-poster.png"
     caption="Starting from Simple's default grayscale, enabling seed colors, then dragging around the color wheel in the design panel. Controls using the generated semantic brushes update without navigation." %}

Picture a "pick your accent color" setting in your app, wired to one property. That's the part I like most about this API.

One gotcha: the helper's properties throw if no theme is merged into the application's resources. If you'd rather not risk that, `SemanticThemeHelper.GetTheme()` is the non-throwing option and just returns `null` when it can't find one. And if you're hosting multiple applications in one process, reach for `someApplication.GetTheme()` to grab the theme you actually mean instead of leaning on `Application.Current`.

## Preparing for 8.0

In the current 8.0 branch, seed generation stays opt-in. An app that never sets `PrimarySeed` keeps its built-in color palette, so you're safe there. It's the other style and font customizations that deserve a closer look. Here are the changes I'd start preparing for now, and definitely circle back to the [migration guide][migration-docs] once the packages actually ship:

- **Seeded colors:** expect different output when moving from 7.x to the upcoming release. `TonalSpot` keeps the previous recipe, but the color-math fix still applies.
- **Root fonts:** plan to replace `TypefacePlain` and `TypefaceBrand` overrides with `DefaultFontFamily`. The 8.0 branch also removes Simple's `SimpleFontFamily` and its old per-weight family keys, so lean on the root family and the relevant `*FontWeight` tokens instead.
- **Material fonts:** in the 8.0 branch, overriding `MaterialRegularFontFamily`, `MaterialMediumFontFamily`, or `MaterialLightFontFamily` no longer changes Material v2 typography. Those keys remain for compatibility, and the v1 styles are unchanged. Move v2 font customization to the new root or specific scale keys.
- **Custom theme subclasses:** the 8.0 branch marks `UseHighFidelityColors` obsolete in favor of `ThemeColors.SeedColorMode`. Your existing overrides still work unless you set an explicit mode on `Colors`.

And if you're coming from an even earlier version, give the guide's v7 section a read too for the other style and API changes.

## Conclusion

The Semantic Design Language gives your app a consistent vocabulary across design systems, and Semantic Design Tokens put the values behind that vocabulary in your hands. You reference `FilledButtonStyle`, `Space400`, `BodyLarge`, and a `PrimarySeed`, and the active theme fills in the specifics. Simple and Material show how that vocabulary can produce different looks from the same markup. Whether you start with Simple's neutral defaults or Material's established look, the shared tokens give you the same place to shape your app's spacing, corners, typography, and colors.

That shared foundation already exists today in 7.x. The work going into 8.0 just makes it easier to swap fonts, adjust tokens at runtime, and generate colors that stay true to your seed. I'm genuinely looking forward to getting these refinements into a proper release. In the meantime, go try the development demo, poke around the branch, and let me know what you build with it.

Hope you learned something and I'll catch you in the next one :wave:

## Further Reading

- [Uno.Themes Overview][themes-overview-docs]
- [Semantic Styles][semantic-styles-docs]
- [Semantic Design Tokens][design-tokens-docs]
- [Seed Color Palette Generation][seed-colors-docs]
- [Uno Simple: Getting Started][simple-getting-started-docs]
- [Upgrading to Uno Themes v8][migration-docs]
- [ThemeStudio on GitHub][theme-studio]

[themes-overview-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/themes-overview.html
[simple-getting-started-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/simple-getting-started.html
[semantic-styles-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/semantic-styles.html
[design-tokens-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/design-tokens.html
[seed-colors-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/seed-colors.html
[migration-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/material-migration.html#upgrading-to-uno-themes-v8
[theme-studio-snapshot]: https://github.com/kazo0/ThemeStudio/tree/18687f1448b6138d23ccd972ccef9128913959da
[theme-studio]: https://github.com/kazo0/ThemeStudio
{% include links.md %}
