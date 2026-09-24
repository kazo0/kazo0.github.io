---
title: "Semantic Design Language and Design Tokens in Uno.Themes 8.0"
category: uno-general
header:
  teaser: /assets/images/simple-design-semantic-tokens/hero.png
  og_image: /assets/images/simple-design-semantic-tokens/hero.png
tags: [uno-themes, simple, semantic-tokens, design-tokens, theming, material, uno-platform, uno, unoplatform]
---

A little while back I wrote about [hosting three Uno apps inside a single Uno app]({% post_url 2026-08-11-alc-super-themes-app %}) so you could flip between Material, Cupertino, and Simple live. That demo gets at something I've been meaning to dig into: the Semantic Design Language in `Uno.Themes`. How do you describe the styles, spacing, typography, and colors your UI needs without tying every choice to one design system?

The Semantic Design Language gives your XAML a shared vocabulary, with semantic styles to describe controls and Semantic Design Tokens to define the values they use. That theme-agnostic layer arrived in `Uno.Themes` 7.0 alongside the new Simple Design System, and it brings a common way to style and customize both Simple and Material. The 8.0 release rounds that story out with a real spacing base unit, a single root typeface, tokens you can tweak at runtime, and seed colors that actually match the color you picked. This post covers the whole picture as it stands in 8.0. If you've ever wanted to re-skin an entire app from a handful of knobs, or swap design systems without a find-and-replace rampage through your styles, this is the release you've been waiting for.

Let's dive in.

<a href="/assets/images/simple-design-semantic-tokens/hero.png" class="image-popup"><img class="align-center" src="/assets/images/simple-design-semantic-tokens/hero.png" alt="The same Forma overview screen rendered side by side under SimpleTheme, in its default grayscale palette, and MaterialTheme, in its default purple palette, with identical layout and content but different colors, control shapes, and typography"/></a>

Everything you'll see in this post comes from [ThemeStudio][theme-studio], a small demo app I put together that lets you flip design systems, seed colors, and tokens live. Same XAML in both halves of that screenshot, each theme wearing its out-of-the-box palette, and I promise I didn't touch a single style key between them.

## The Problem With Theme-Prefixed Styles

Here's the thing that's always bugged me a little about styling Uno apps. If you wanted a filled button under Material, you reached for `MaterialFilledButtonStyle`:

```xml
<Button Style="{StaticResource MaterialFilledButtonStyle}" Content="Save" />
```

That works great, right up until the day you want to try a different design system. Now every one of those `Material*` keys is wrong, and you're spelunking through your XAML swapping prefixes and praying you didn't miss one. Your markup is welded to a single design system, and there's no clean way to say "give me a filled button, whatever that means for the theme that's currently active."

That is the problem the Semantic Design Language addresses: your XAML describes the role a style or resource plays, and the active theme supplies its design.

## Semantic Styles: One Key, Any Theme

Now for the good part. Instead of `MaterialFilledButtonStyle`, the new semantic layer gives you a single unprefixed key:

```xml
<!-- Works under both Material and Simple. No edits required. -->
<Button Style="{StaticResource FilledButtonStyle}" Content="Save" />
```

That exact XAML renders a proper Material filled button under `MaterialTheme` and a proper Simple filled button under `SimpleTheme`. You don't change a thing.

The mechanism is refreshingly boring, which I mean as the highest compliment. Each theme's `_Resources.xaml` defines a `StaticResource` alias that points the semantic key at the theme's concrete style:

- Under Material, `FilledButtonStyle` resolves to `MaterialFilledButtonStyle`
- Under Simple, `FilledButtonStyle` resolves to `SimpleFilledButtonStyle`

Same idea across the board: `OutlinedTextBoxStyle`, `ContentDialogStyle`, `ComboBoxStyle`, the full Material Design 3 typography scale (`HeadlineLarge`, `BodyMedium`, `LabelSmall`, and friends), all of it. Write the semantic key, let the active theme sort out the details.

Now, a bit of honesty, because the two design systems don't have perfectly overlapping vocabularies. A few Material concepts simply don't exist in Simple. `ElevatedButtonStyle` has no shadow-based equivalent, `CommandBarStyle` and `MediaTransportControlsStyle` aren't implemented for Simple, and the whole Floating Action Button family maps onto Simple's icon buttons rather than a true FAB. None of that will crash on you, but if you're writing genuinely theme-agnostic markup, stick to the keys that exist on both sides. The [semantic styles docs][semantic-styles-docs] have the complete mapping table, gaps flagged and all.
{: .notice--warning}

## Semantic Design Tokens: The Shared Vocabulary

Semantic styles are the visible tip. The more interesting change is underneath: a shared set of Semantic Design Tokens. These are XAML resources for spacing, shape, density, and typography that every control template now references. Override one token key globally and every control that consumes it moves in lockstep.

Spacing is a numeric scale, roughly following a familiar design-token naming convention:

| Key | Value (px) | Thickness Key |
| --- | --- | --- |
| `Space100` | 4 | `Space100Thickness` |
| `Space200` | 8 | `Space200Thickness` |
| `Space300` | 12 | `Space300Thickness` |
| `Space400` | 16 | `Space400Thickness` |
| `Space600` | 24 | `Space600Thickness` |

Shape (corner radius) works the same way, from `Radius0` all the way up to `RadiusFull` (a 9999px "just make it a pill" value):

| Key | Value (px) | CornerRadius Key |
| --- | --- | --- |
| `Radius100` | 4 | `Radius100CornerRadius` |
| `Radius200` | 8 | `Radius200CornerRadius` |
| `Radius400` | 16 | `Radius400CornerRadius` |
| `RadiusFull` | 9999 | `RadiusFullCornerRadius` |

And density covers control heights and icon sizes (`ControlHeightMedium`, `IconSizeMedium`, `TouchTargetMinSize`, and so on).

Want slightly rounder corners everywhere without touching a single control style? Override the token:

```xml
<Page.Resources>
    <CornerRadius x:Key="Radius200CornerRadius">10</CornerRadius>
</Page.Resources>
```

Every control that uses `Radius200CornerRadius` picks it up. That's the whole point.

## Simple and Material: Two Takes on the Same Language

With that shared vocabulary in place, the choice of design system becomes about how you want your app to look. Simple (SDS, if you like acronyms) is Uno's own low-opinion, neutral design system. Where Material comes with strong Material Design opinions baked in, Simple ships a clean grayscale palette and gets out of your way, which makes it a lovely starting point when you want to bring your own brand rather than adopt someone else's.

Both themes use the semantic styles and tokens above; Simple is a useful starting point for seeing how far those shared resources can take your own design. To try it, add one `UnoFeatures` entry:

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

Or if you're starting fresh, the template has you covered:

```bash
dotnet new unoapp -o UnoSimpleApp -theme simple
```

Out of the box Simple is intentionally plain. No default seed color, just a neutral grayscale palette that stays grayscale until you give it something to work with. We'll give it something to work with shortly. :wink:

## Turning the Big Knobs

Overriding individual Semantic Design Tokens is great for surgical tweaks, but the tokens also roll up into a few scalar properties on the theme itself. Material and Simple expose the same knobs, so you can reshape an entire app from `App.xaml` using either theme.

`DefaultCornerRadius` and `DefaultSpacing` each generate a full scale from a single base value:

```xml
<!-- Every Radius* becomes a multiple of 2, every Space* a multiple of 6 -->
<MaterialTheme xmlns="using:Uno.Material" DefaultCornerRadius="2" DefaultSpacing="6" />
```

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

One property, and every control in the app breathes in or out. Control heights and icon sizes stay put, it's only the padding and margins that move. The first time I flipped a real screen from `Regular` to `Compact` I genuinely grinned. It's the kind of thing I've hand-tuned control by control more times than I'd like to admit.

Typography gets the same treatment. `DefaultFontFamily` is the single root the entire type scale derives from, so swapping the font for a whole app is one property instead of nineteen `*FontFamily` overrides:

```xml
<SimpleTheme xmlns="using:Uno.Simple" DefaultFontFamily="ms-appx:///Fonts/MyFont.ttf#MyFont" />
```

Point it at a variable font, or one shipping a font manifest, so the per-scale `*FontWeight` tokens still render the way the type scale intends.

All four of these knobs are runtime-settable. Assigning one regenerates the tokens, and anything created afterwards picks up the new scale. Controls already on screen keep the values they resolved when they loaded, because these are plain `Thickness`, `CornerRadius`, and `FontFamily` values rather than live brushes. Their styles read the tokens through `ThemeResource` though, so a theme-change pass (toggle the root's `RequestedTheme` away from its `ActualTheme` and back) re-resolves everything in place. That's exactly the trick behind the sliders in ThemeStudio. Colors, as you're about to see, don't even need that much.
{: .notice--info}

## Semantic Color From a Single Seed

The last piece, and honestly the flashiest, is color. Historically, theming an app meant defining 30-plus color resources across Light and Dark. That's a lot of hex codes to keep in sync, and I have absolutely shipped a Dark theme with one stubbornly-wrong shade because I fat-fingered a copy-paste. :sweat_smile:

The new seed color generation takes a single color and derives the entire semantic palette for you, using the Material Design 3 HCT (Hue-Chroma-Tone) color space. You set a `PrimarySeed` on a `ThemeColors` object, and out comes `Primary`, `Secondary`, `Tertiary`, all the `Surface` and `Outline` roles, for both Light and Dark, at the correct M3 tone levels (`Error` stays pinned to its fixed hue, as M3 prescribes):

```xml
<us:SimpleTheme xmlns:us="using:Uno.Simple">
    <us:SimpleTheme.Colors>
        <ut:ThemeColors xmlns:ut="using:Uno.Themes"
                        PrimarySeed="#6750A4" />
    </us:SimpleTheme.Colors>
</us:SimpleTheme>
```

The palette uses the same semantic color roles under either theme. In this Simple example, one seed turns the default grayscale into a full palette. Secondary and Tertiary are auto-derived from the primary, though you can pin them explicitly if you want more control.

8.0 also changed *what* comes out of the generator. The default `SeedColorMode` is now `Fidelity`: in Light mode your `Primary` is the seed color verbatim, `OnPrimary` is picked automatically to clear WCAG AA contrast, and the supporting palettes follow your seed's saturation, so a muted brand color gives you a muted theme instead of Material's always-vibrant interpretation of it. If you'd rather have the classic M3 recipe, set `SeedColorMode="TonalSpot"` on the same `ThemeColors` object.

It even works at runtime. The semantic brushes are long-lived instances whose colors get rewritten in place, so everything already on screen repaints immediately, hover and pressed variants included, with no page re-navigation and no theme toggle:

```csharp
using Uno.Themes;
using Windows.UI;

// Rebrand the whole app on the fly
SemanticThemeHelper.PrimarySeed = Colors.Green;

// Back to the theme's default look
SemanticThemeHelper.PrimarySeed = null;
```

{% include local-video.html
     src="/assets/images/simple-design-semantic-tokens/seed-runtime.mp4"
     poster="/assets/images/simple-design-semantic-tokens/seed-runtime-poster.png"
     caption="Starting from Simple's default grayscale, then setting PrimarySeed and sweeping it through the hue wheel at runtime. Every brush in the app follows, no navigation required." %}

Picture a "pick your accent color" setting in your app, wired to one property. That used to be a small project. Now it's a one-liner.

If you're already on Material and this is making you nervous, don't be. Seed generation is opt-in, off unless you turn it on, and neither 7.0 nor 8.0 renamed or removed a single color or brush key, so an app that never sets a seed renders with exactly the colors it had before. Two things to know if you're upgrading: apps that *do* use a seed will see more vivid palettes in 8.0 (a color-math fix plus the new `Fidelity` default, with `TonalSpot` as the escape hatch), and the short-lived `TypefacePlain` / `TypefaceBrand` font tokens are gone in favor of `DefaultFontFamily`. Both are spelled out in the [migration guide][migration-docs].
{: .notice--info}

## Conclusion

The Semantic Design Language gives your app a consistent vocabulary across design systems, and Semantic Design Tokens put the values behind that vocabulary in your hands. You reference `FilledButtonStyle`, `Space400`, `BodyLarge`, and a `PrimarySeed`, and the active theme fills in the specifics. Simple and Material show how that vocabulary can produce different looks from the same markup. Whether you start with Simple's neutral defaults or Material's established look, the shared tokens give you the same place to shape your app's spacing, corners, typography, and colors.

There's a lot more here than one post can hold, especially around lightweight styling and the per-control resource keys, so go poke at the docs below. And if you build something fun by pointing a `PrimarySeed` at your brand color, I'd love to see it.

Hope you learned something and I'll catch you in the next one :wave:

## Further Reading

- [Semantic Styles][semantic-styles-docs]
- [Semantic Design Tokens][design-tokens-docs]
- [Seed Color Palette Generation][seed-colors-docs]
- [Uno Simple: Getting Started][simple-getting-started-docs]
- [Upgrading to Uno Themes v8][migration-docs]
- [ThemeStudio on GitHub][theme-studio]

[simple-getting-started-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/simple-getting-started.html
[semantic-styles-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/semantic-styles.html
[design-tokens-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/design-tokens.html
[seed-colors-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/seed-colors.html
[migration-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/material-migration.html#upgrading-to-uno-themes-v8
[theme-studio]: https://github.com/kazo0/ThemeStudio
{% include links.md %}
</content>
