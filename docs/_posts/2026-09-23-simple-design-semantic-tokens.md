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

We'll start with the shared vocabulary introduced in 7.x, then look at the current 8.0 implementation. The examples focus on Material and Simple; sharing a library with Cupertino doesn't mean all three expose the same semantic styles.

<!-- Fact-checked against uno.themes servicing/8.0 at 5a0b9ddb30e40b5d8929f7212b858357497ec0c0 and the live development docs on 2026-09-30. -->

Let's dive in.

<a href="/assets/images/simple-design-semantic-tokens/simple-vs-material.png" class="image-popup"><img class="align-center" src="/assets/images/simple-design-semantic-tokens/simple-vs-material.png" alt="The same Forma overview screen rendered side by side under SimpleTheme, in its default grayscale palette, and MaterialTheme, in its default purple palette, with identical layout and content but different colors, control shapes, and typography"/></a>

Everything you'll see in this post comes from [ThemeStudio][theme-studio], a small demo app I put together that lets you flip design systems, seed colors, and tokens live. Same XAML in both halves of that screenshot, each theme wearing its out-of-the-box palette, and I promise I didn't touch a single style key between them.

## The Problem With Theme-Prefixed Styles

Here's the thing that's always bugged me a little about styling Uno apps. If you wanted a filled button under Material, you reached for `MaterialFilledButtonStyle`:

```xml
<Button Style="{StaticResource MaterialFilledButtonStyle}" Content="Save" />
```

That works great, right up until the day you want to try a different design system. Now every one of those `Material*` keys is wrong, and you're spelunking through your XAML swapping prefixes and praying you didn't miss one. Your markup is welded to a single design system, and there's no clean way to say "give me a filled button, whatever that means for the theme that's currently active."

That is the problem the Semantic Design Language addresses: your XAML describes the role a style or resource plays, and the active theme supplies its design.

## Semantic Styles: One Key, Two Design Systems

Now for the good part. Instead of `MaterialFilledButtonStyle`, the semantic layer introduced in 7.x gives you a single unprefixed key:

```xml
<!-- Works under both Material and Simple. No edits required. -->
<Button Style="{StaticResource FilledButtonStyle}" Content="Save" />
```

That exact XAML renders a proper Material filled button under `MaterialTheme` and a proper Simple filled button under `SimpleTheme`. You don't change a thing.

The mechanism is refreshingly boring, which I mean as the highest compliment. Each theme's `_Resources.xaml` defines a `StaticResource` alias that points the semantic key at the theme's concrete style:

- Under Material, `FilledButtonStyle` resolves to `MaterialFilledButtonStyle`
- Under Simple, `FilledButtonStyle` resolves to `SimpleFilledButtonStyle`

Same idea across the board: `OutlinedTextBoxStyle`, `ContentDialogStyle`, `ComboBoxStyle`, the full Material Design 3 typography scale (`HeadlineLarge`, `BodyMedium`, `LabelSmall`, and friends), all of it. Write the semantic key, let the active theme sort out the details.

The two design systems don't have perfectly overlapping vocabularies. Simple does not define the `ElevatedButtonStyle`, `CommandBarStyle`, or `MediaTransportControlsStyle` aliases, so don't reference those keys expecting a Simple equivalent. The Floating Action Button aliases do exist, but map to Simple icon buttons rather than distinct FAB styles. Even a shared key can have a different interpretation: `OutlinedButtonStyle` maps to Simple's tonal button. Check the [semantic styles mapping table][semantic-styles-docs] when choosing the keys your app depends on.
{: .notice--warning}

## Semantic Design Tokens: The Shared Vocabulary

Semantic styles are the visible tip. Underneath is the other part of that shared foundation: Semantic Design Tokens. These are XAML resources for spacing, shape, control sizing, and typography, consumed by the design systems' styles and templates. An override affects the controls that reference that resource; it does not rewrite a local value you hard-coded on a control.

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

Controls resolving `Radius200CornerRadius` in that scope can use the override. It doesn't change `Radius200` or other corner-radius keys automatically. Likewise, a numeric `Space200` and its `Space200Thickness` companion are separate resources: override the form your style consumes, or use the theme properties below to regenerate the whole scale.

## Simple and Material: Two Takes on the Same Language

With that shared vocabulary in place, the choice of design system becomes about how you want your app to look. Uno Simple implements Figma's Simple Design System (SDS). Where Material comes with strong Material Design opinions baked in, Simple ships a clean grayscale palette and gets out of your way, which makes it a lovely starting point when you want to bring your own brand rather than adopt someone else's.

Both themes use the semantic styles and tokens above; Simple is a useful starting point for seeing how far those shared resources can take your own design.

### Trying the Preview

For a runnable demo, start with [this ThemeStudio snapshot][theme-studio-snapshot]. It pins `Uno.Material.WinUI` and `Uno.Simple.WinUI` to `9.0.0-dev.2`, with `Uno.Themes.WinUI` resolving transitively to the same version. Those are development packages, not an 8.0 release. The color-wheel video uses that build with the picker's `ColorSpectrumShape` set to `Ring`; the API descriptions in this post are checked against `servicing/8.0`. To test the exact branch implementation, build the libraries from that branch and use those builds in your app.

The configuration below shows how to wire up Simple; the later 8.0-specific examples assume library builds with those APIs. Adding `SimpleTheme` or running the template command alone does not opt you into the unreleased functionality.

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

If you're starting fresh, the template can create the Simple setup; you still need to select suitable development packages or source builds for the preview features:

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

`Radius200` is now 4 and `Space200` is 12; the corresponding `CornerRadius` and `Thickness` resources are generated too. `RadiusFull` stays 9999.

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

The `Space*` resources change, while `ControlHeight*`, `IconSize*`, and `TouchTargetMinSize` keep their fixed values. Padding and margins that use the spacing resources follow the new scale; hard-coded spacing doesn't. Actual layout still depends on content and constraints, so this isn't a promise that every rendered control keeps exactly the same height.

The upcoming release also brings typography under a single root. In the 8.0 branch, `DefaultFontFamily` is the root for the semantic type scale, so changing the font used by the design system is one property:

```xml
<SimpleTheme xmlns="using:Uno.Simple" DefaultFontFamily="ms-appx:///Fonts/MyFont.ttf#MyFont" />
```

Point it at a variable font, or one shipping a font manifest, so the per-scale `*FontWeight` tokens still render the way the type scale intends. Font overrides take precedence over the generated family keys.

This applies to text styled by the design system. An unstyled `TextBlock` uses the framework's default font instead; changing `DefaultFontFamily` doesn't change that separate default. The [typography guide][design-tokens-docs] covers both the property and the `FontOverrideSource` route.

In the 8.0 branch, all four of these knobs are runtime-settable. Assigning one regenerates the tokens, and anything created afterwards picks up the new scale. Controls already on screen keep the values they resolved when they loaded, because these are plain `Thickness`, `CornerRadius`, and `FontFamily` values rather than live brushes. Their styles read the tokens through `ThemeResource` though, so a theme-change pass (toggle the root's `RequestedTheme` away from its `ActualTheme` and back) re-resolves everything in place. Recreating the root content is another way to pick up the regenerated resources. Colors, as you're about to see, use a different update mechanism.
{: .notice--info}

## Semantic Color From a Single Seed

The last piece, and honestly the flashiest, is color. Historically, theming an app meant defining 30-plus color resources across Light and Dark. That's a lot of hex codes to keep in sync, and I have absolutely shipped a Dark theme with one stubbornly-wrong shade because I fat-fingered a copy-paste. :sweat_smile:

Seed color generation uses the Material Design 3 HCT (Hue-Chroma-Tone) color model to build Light and Dark palettes from a `PrimarySeed` on `ThemeColors`. It supplies primary, secondary, tertiary, surface, and outline roles. The four `Error*` colors are excluded from generation and keep their base-palette values unless you explicitly override them:

```xml
<us:SimpleTheme xmlns:us="using:Uno.Simple">
    <us:SimpleTheme.Colors>
        <ut:ThemeColors xmlns:ut="using:Uno.Themes"
                        PrimarySeed="#6750A4" />
    </us:SimpleTheme.Colors>
</us:SimpleTheme>
```

The palette uses the same semantic color roles under either theme. In this Simple example, one seed turns the default grayscale into a full palette. Secondary and Tertiary are auto-derived from the primary, though you can pin them explicitly if you want more control.

8.0 will also change *what* comes out of the generator. In the current implementation, the default `SeedColorMode` is `Fidelity`: in Light mode, the generated `PrimaryColor` keeps the seed's RGB value, with alpha treated as fully opaque. The generator chooses `OnPrimaryColor` to give that pair at least 4.5:1 contrast. Supporting palettes follow the seed's chroma, so a muted seed produces a muted palette and a gray seed stays neutral. In Dark mode, `PrimaryColor` uses a lighter tone derived from the seed instead of the exact input color.

If you'd rather use the Material tonal-spot recipe, set `SeedColorMode="TonalSpot"` on the same `ThemeColors` object. That recipe applies minimum chroma rather than preserving the seed's exact Light primary. It does **not** reproduce 7.x colors exactly: the 8.0 branch also contains a color-math fix for washed-out saturated seeds.

Explicit color overrides still win. Values in `ThemeColors.OverrideDictionary` or the dictionary loaded through `OverrideSource` take precedence over generated colors, which in turn take precedence over the theme's built-in palette. The contrast guarantee above describes the generated primary pair; replacing either color yourself changes that pairing.

The 8.0 implementation also improves runtime updates. The semantic brushes are long-lived instances whose colors get rewritten in place, so controls using those brushes repaint without page re-navigation or a theme toggle, including hover and pressed variants. A brush you explicitly override still takes precedence. With a theme already merged into `Application.Current.Resources`, the helper makes this straightforward:

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

The helper's properties throw if no theme is merged into the application's resources; `SemanticThemeHelper.GetTheme()` is the non-throwing option and returns `null` when none is found. If you're hosting multiple applications, use `someApplication.GetTheme()` to select the intended application's theme instead of relying on `Application.Current`.

## Preparing for 8.0

In the current 8.0 branch, seed generation remains opt-in. An app that never sets `PrimarySeed` keeps its built-in color palette, but other style and font customizations need a closer look. Ahead of the release, these are the changes to prepare for; check the [migration guide][migration-docs] again when the packages ship:

- **Seeded colors:** expect different output when moving from 7.x to the upcoming release. `TonalSpot` keeps the previous recipe, but the color-math fix still applies.
- **Root fonts:** plan to replace `TypefacePlain` and `TypefaceBrand` overrides with `DefaultFontFamily`. The 8.0 branch removes Simple's `SimpleFontFamily` and its old per-weight family keys too; use the root family and the relevant `*FontWeight` tokens.
- **Material fonts:** in the 8.0 branch, overriding `MaterialRegularFontFamily`, `MaterialMediumFontFamily`, or `MaterialLightFontFamily` no longer changes Material v2 typography. Those keys remain for compatibility, and the v1 styles are unchanged. Move v2 font customization to the new root or specific scale keys.
- **Custom theme subclasses:** the 8.0 branch marks `UseHighFidelityColors` obsolete. Use `ThemeColors.SeedColorMode`; existing overrides still work unless an explicit mode is set on `Colors`.

When testing a development build ahead of a 7.x-to-8.0 upgrade, check font overrides as well as seed colors. If you're coming from an earlier version, also read the guide's v7 section for the other style and API changes.

## Conclusion

The Semantic Design Language gives your app a consistent vocabulary across design systems, and Semantic Design Tokens put the values behind that vocabulary in your hands. You reference `FilledButtonStyle`, `Space400`, `BodyLarge`, and a `PrimarySeed`, and the active theme fills in the specifics. Simple and Material show how that vocabulary can produce different looks from the same markup. Whether you start with Simple's neutral defaults or Material's established look, the shared tokens give you the same place to shape your app's spacing, corners, typography, and colors.

That shared foundation already exists in 7.x; the work on 8.0 makes it easier to change fonts, adjust tokens at runtime, and generate colors that stay true to your seed. I'm looking forward to getting these refinements into a release. In the meantime, try the development demo, explore the branch, and let me know what you build with it.

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
