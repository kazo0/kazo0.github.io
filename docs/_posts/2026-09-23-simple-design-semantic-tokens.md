---
title: "Simple Design and Semantic Tokens in Uno.Themes 7.0"
category: uno-general
header:
  teaser: /assets/images/simple-design-semantic-tokens/hero.png
  og_image: /assets/images/simple-design-semantic-tokens/hero.png
tags: [uno-themes, simple, semantic-tokens, design-tokens, theming, material, uno-platform, uno, unoplatform]
---

A little while back I wrote about [hosting three Uno apps inside a single Uno app]({% post_url 2026-08-11-alc-super-themes-app %}) so you could flip between Material, Cupertino, and Simple live. That post was really a demo wrapper around something bigger that's been happening in `Uno.Themes`, and I've been meaning to talk about the something bigger. So here we are.

`Uno.Themes` just shipped its 7.0 release, and it's a big one. There's a brand new Simple Design System, and underneath it a whole semantic token layer that finally lets you write theme-agnostic XAML. If you've ever wanted to re-skin an entire app from a handful of knobs, or swap design systems without a find-and-replace rampage through your styles, this is the release you've been waiting for.

Let's dive in.

<!-- TODO: hero image / side-by-side of the same app under Material vs Simple -> /assets/images/simple-design-semantic-tokens/hero.png -->

## The Problem With Theme-Prefixed Styles

Here's the thing that's always bugged me a little about styling Uno apps. If you wanted a filled button under Material, you reached for `MaterialFilledButtonStyle`:

```xml
<Button Style="{StaticResource MaterialFilledButtonStyle}" Content="Save" />
```

That works great, right up until the day you want to try a different design system. Now every one of those `Material*` keys is wrong, and you're spelunking through your XAML swapping prefixes and praying you didn't miss one. Your markup is welded to a single design system, and there's no clean way to say "give me a filled button, whatever that means for the theme that's currently active."

That welding is exactly what the new semantic layer melts away.

## Meet the Simple Design System

Before we get to tokens, let's meet the new design system that motivated a lot of this work. Simple (SDS, if you like acronyms) is Uno's own low-opinion, neutral design system. Where Material comes with strong Material Design opinions baked in, Simple ships a clean grayscale palette and gets out of your way, which makes it a lovely starting point when you want to bring your own brand rather than adopt someone else's.

Turning it on is one `UnoFeatures` entry:

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

## Design Tokens: The Shared Vocabulary

Semantic styles are the visible tip. The more interesting change is underneath: a shared set of design tokens. These are semantic XAML resources for spacing, shape, density, and typography that every control template now references. Override one token key globally and every control that consumes it moves in lockstep.

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

## Turning the Big Knobs

Overriding individual tokens is great for surgical tweaks, but the tokens also roll up into a few scalar properties on the theme itself, so you can reshape an entire app from `App.xaml`.

`DefaultCornerRadius` and `DefaultSpacing` each generate a full scale from a single base value:

```xml
<!-- Every Radius* becomes a multiple of 4, every Space* a multiple of 6 -->
<MaterialTheme DefaultCornerRadius="4" DefaultSpacing="6" />
```

And my personal favorite, `DefaultDensity`, which dials the padding across your whole app between three presets:

```xml
<!-- Tighten everything up for a data-dense screen -->
<SimpleTheme xmlns="using:Uno.Simple" DefaultDensity="Compact" />
```

| `DefaultDensity` | Base Spacing | Feel |
| --- | :---: | --- |
| `Compact` | 3 | Tighter padding for data-dense UIs |
| `Regular` (default) | 4 | Balanced spacing |
| `Comfy` | 5 | More generous padding |

<!-- TODO: screenshot comparing Compact vs Regular vs Comfy density on the same screen -> /assets/images/simple-design-semantic-tokens/density.png -->

One property, and every control in the app breathes in or out. The first time I flipped a real screen from `Regular` to `Compact` I genuinely grinned. It's the kind of thing I've hand-tuned control by control more times than I'd like to admit.

## Semantic Color From a Single Seed

The last piece, and honestly the flashiest, is color. Historically, theming an app meant defining 30-plus color resources across Light and Dark. That's a lot of hex codes to keep in sync, and I have absolutely shipped a Dark theme with one stubbornly-wrong shade because I fat-fingered a copy-paste. :sweat_smile:

The new seed color generation takes a single color and derives the entire semantic palette for you, using the Material Design 3 HCT (Hue-Chroma-Tone) color space. You set a `PrimarySeed` on a `ThemeColors` object, and out comes `Primary`, `Secondary`, `Tertiary`, `Error`, all the `Surface` and `Outline` roles, for both Light and Dark, at the correct M3 tone levels:

```xml
<us:SimpleTheme xmlns:us="using:Uno.Simple">
    <us:SimpleTheme.Colors>
        <ut:ThemeColors xmlns:ut="using:Uno.Themes"
                        PrimarySeed="#6750A4" />
    </us:SimpleTheme.Colors>
</us:SimpleTheme>
```

That's the "something to work with" I promised Simple earlier. ONE line, and the grayscale gives way to a full, cohesive palette. Secondary and Tertiary are auto-derived from the primary, though you can pin them explicitly if you want more control.

It even works at runtime. The library patches the existing `SolidColorBrush` instances in place, so the UI recolors itself with no page re-navigation:

```csharp
using Uno.Themes;
using Windows.UI;

// Rebrand the whole app on the fly
SemanticThemeHelper.PrimarySeed = Colors.Green;

// Back to the theme's default look
SemanticThemeHelper.PrimarySeed = null;
```

<!-- TODO: screen recording of runtime seed color change recoloring the app -> /assets/images/simple-design-semantic-tokens/seed-runtime.mp4 -->

Picture a "pick your accent color" setting in your app, wired to one property. That used to be a small project. Now it's a one-liner.

If you're already on Material and this is making you nervous, don't be. Seed generation is opt-in, off unless you turn it on, and the 7.0 release didn't rename or remove a single color or brush key. Existing apps upgrade with their visuals untouched. You only get the new behavior when you ask for it.
{: .notice--info}

## Conclusion

The through-line here is simple: your XAML stops caring which design system it renders under. You reference `FilledButtonStyle`, `Space400`, `BodyLarge`, and a `PrimarySeed`, and the active theme fills in the specifics. That's what made the [three-themes-in-one-app demo]({% post_url 2026-08-11-alc-super-themes-app %}) possible in the first place, and it's what makes bringing your own brand to a Simple app a few lines of work instead of a few days.

There's a lot more here than one post can hold, especially around lightweight styling and the per-control resource keys, so go poke at the docs below. And if you build something fun by pointing a `PrimarySeed` at your brand color, I'd love to see it.

Hope you learned something and I'll catch you in the next one :wave:

## Further Reading

- [Uno Simple: Getting Started][simple-getting-started-docs]
- [Semantic Styles][semantic-styles-docs]
- [Design Tokens][design-tokens-docs]
- [Seed Color Palette Generation][seed-colors-docs]

[simple-getting-started-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/simple-getting-started.html
[semantic-styles-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/semantic-styles.html
[design-tokens-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/design-tokens.html
[seed-colors-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/seed-colors.html
{% include links.md %}
</content>
