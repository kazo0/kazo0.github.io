---
title: "Semantic Design in Uno Themes - Part 1"
category: uno-general
header:
  teaser: /assets/images/simple-design-semantic-tokens/hero.jpg
  og_image: /assets/images/simple-design-semantic-tokens/hero.jpg
tags: [uno-themes, simple, semantic-tokens, design-tokens, theming, material, uno-platform, uno, unoplatform]
---

A little while back I wrote about [hosting three Uno apps inside a single Uno app]({% post_url 2026-08-11-alc-super-themes-app %}) so you could flip between Material, Cupertino, and Simple live. That demo got at something I've been meaning to dig into properly: the [Semantic Design Language][semantic-styles-docs] in `Uno Themes`. How do you describe the styles, spacing, typography, and colors your UI needs without welding every choice to one design system?

The Semantic Design Language gives your XAML a shared vocabulary. Semantic styles describe your controls, and [Semantic Design Tokens][design-tokens-docs] define the values those controls use. Uno Themes 7.0 introduced that shared layer alongside the new Simple design system. Material and Simple both speak the same vocabulary, so you can customize either one without scattering design-system-specific keys all through your markup.

This is the first of two posts. Here in Part 1 we'll wrap our heads around that shared vocabulary as it exists today in 7.x: the semantic styles, the tokens underneath them, the scalar knobs for reshaping those tokens wholesale, and how Simple and Material each interpret them. In [Part 2]({% post_url 2026-10-04-uno-themes-8-runtime-seed-colors %}) I'll look at what the upcoming 8.0 release adds on top, like knobs that reach your controls at runtime, a single root font, and seed colors that stay true to your brand and repaint live. I'm focusing on Material and Simple throughout.

Let's dive in. :diving_mask:

<figure>
    <a href="/assets/images/simple-design-semantic-tokens/simple-vs-material.png" class="image-popup"><img class="align-center" src="/assets/images/simple-design-semantic-tokens/simple-vs-material.png" alt="The same Forma overview screen rendered side by side under SimpleTheme, in its default grayscale palette, and MaterialTheme, in its default purple palette, with identical layout and content but different colors, control shapes, and typography"/></a>
    <figcaption>The same screen under SimpleTheme (left) and MaterialTheme (right), each with its default palette.</figcaption>
</figure>

Everything you'll see in this post comes from [ThemeStudio][theme-studio], a little demo app I put together that lets you flip design systems, seed colors, and tokens live. Same XAML in both halves of that screenshot, each theme wearing its out-of-the-box palette, and I promise I didn't touch a single style key between them.

## The Problem With Theme-Prefixed Styles

The problem with theme-prefixed styles is that you need to <i><u>prefix</u></i> the <i><u>theme</u></i> for every <i><u>style</u></i> key... make sense?

```xml
<Button Style="{StaticResource MaterialFilledButtonStyle}" Content="Save" />
```

That works great, right up until the day you want to try a different design system. Now every one of those `Material*` keys is wrong, and you're spelunking through your XAML swapping prefixes and praying you didn't miss one. Your markup is welded to a single design system, and there's no clean way to say "give me a filled button, whatever that means for the theme that's currently active."

That's exactly the problem the Semantic Design Language solves. Your XAML describes the ROLE a style or resource plays, and the active theme fills in the design.

## Semantic Styles

Now for the good part. Instead of `MaterialFilledButtonStyle`, the semantic layer <i>un-</i>prefixes your prefixed styles so that your prefixed keys are no longer prefixed... I told you it was simple:

```xml
<!-- Works under both Material and Simple. No edits required. -->
<Button Style="{StaticResource FilledButtonStyle}" Content="Save" />
```

That exact XAML renders a proper Material filled button under `MaterialTheme` and a proper Simple filled button under `SimpleTheme`. You don't change a thing.

The mechanism behind this is refreshingly boring, and I mean that as a compliment. Internally, each theme defines a set of `StaticResource` alias that points the semantic key at the theme's concrete style:

- Under Material, `FilledButtonStyle` resolves to `MaterialFilledButtonStyle`
- Under Simple, `FilledButtonStyle` resolves to `SimpleFilledButtonStyle`

Same idea across the board: `OutlinedTextBoxStyle`, `ContentDialogStyle`, `ComboBoxStyle`, the full Material Design 3 typography scale (`HeadlineLarge`, `BodyMedium`, `LabelSmall`, and friends), all of it. Write the semantic key, let the active theme sort out the details.

The two design systems don't have perfectly overlapping vocabularies. Simple does not define the `ElevatedButtonStyle`, `CommandBarStyle`, or `MediaTransportControlsStyle` aliases, so don't reference those keys expecting a Simple equivalent. The Floating Action Button aliases do exist, but map to Simple icon buttons rather than distinct FAB styles. Even a shared key can have a different interpretation: `OutlinedButtonStyle` maps to Simple's tonal button. Check the [semantic styles mapping table][semantic-styles-docs] when choosing the keys your app depends on.
{: .notice--warning}

## Semantic Design Tokens

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

Any control that resolves `Radius200CornerRadius` in that scope picks up the override. Just know that it doesn't automatically change `Radius200` or any of the other corner-radius keys. Same goes for spacing: the numeric `Space200` and its `Space200Thickness` companion are separate resources. Override whichever form your style actually consumes, or reach for the scalar theme properties below to regenerate the whole scale at once.

I know you may be thinking: "What kind of name is `Radius200CornerRadius`? Isn't that redundant?"

And my response to that is: Yes, but that's what I decided to name it so you're stuck with it. Every token is related and generated in C# by [`BaseTheme`][base-theme-scale-gen-gh], more on that [next](#scaling-with-base-units).

## Turning the Big Knobs

Overriding tokens one at a time is great for surgical tweaks, but you don't have to work that way. Those scales also roll up into a few scalar properties on the theme itself, so you can reshape a whole app's proportions right from `App.xaml`. Material and Simple both expose them.

`DefaultCornerRadius` and `DefaultDensity` each set a base unit, and the full scale generates from there as multiples of it. `DefaultCornerRadius` is the corner-radius unit, and `DefaultDensity` picks the spacing unit: `Compact`, `Regular`, and `Comfy` mean 3, 4, and 5:

```xml
<SimpleTheme xmlns="using:Uno.Simple"
             DefaultCornerRadius="2"
             DefaultDensity="Compact" />
```

### Scaling with Base Units

At `Compact`, the base spacing unit is 3, so `Space100` is 3, `Space200` is 6, and `Space400` is 12, with the matching `Thickness` resources generated right alongside them. Control heights and icon sizes stay put, so only the padding and margins tighten. `DefaultCornerRadius` does the same thing for the `Radius*` scale, so a base of 2 makes `Radius100` 2 and `Radius400` 8. `RadiusFull` stays 9999 no matter what, because a pill is a pill.

<figure>
    <a href="/assets/images/simple-design-semantic-tokens/density.png" class="image-popup"><img class="align-center" src="/assets/images/simple-design-semantic-tokens/density.png" alt="The same Simple settings screen at Compact, Regular, and Comfy density, showing progressively more generous padding inside cards and inputs while control heights stay the same"/></a>
    <figcaption>One Simple settings screen at Compact, Regular, and Comfy density.</figcaption>
</figure>

## Simple and Material

With that shared vocabulary in place, picking a design system is really just about how you want your app to look. Uno Simple implements Figma's Simple Design System (SDS). Where Material comes with strong Material Design opinions baked in, Simple ships a clean grayscale palette and gets out of your way. That makes it a lovely place to start when you want to bring your own brand rather than adopt someone else's, and a great way to see how far those shared tokens can take your own design.

### Getting Simple Into Your App

Pulling Simple in is a matter of opting into the feature and merging the theme. Add `SimpleTheme` to your project's existing `UnoFeatures` list. A project using only that feature would have:

```xml
<UnoFeatures>SimpleTheme</UnoFeatures>
```

Then merge the theme into your `App.xaml`:

```xml
<Application.Resources>
    <ResourceDictionary>
        <ResourceDictionary.MergedDictionaries>
            <!-- other dictionaries omitted for brevity -->
            <SimpleTheme xmlns="using:Uno.Simple" />
        </ResourceDictionary.MergedDictionaries>
    </ResourceDictionary>
</Application.Resources>
```

Starting from scratch? The template can scaffold the whole thing for you:

```bash
dotnet new unoapp -o UnoSimpleApp -theme simple
```

Out of the box, Simple is intentionally plain. No seed color, just a neutral grayscale palette that stays gray until you give it something to work with. A `PrimarySeed` on the theme's `Colors` already turns it into a full brand palette in 7.x, and how 8.0 makes that palette truer to your brand, and live, is exactly where [Part 2]({% post_url 2026-10-04-uno-themes-8-runtime-seed-colors %}) picks up. :wink:

## Conclusion

That's the shared foundation. Semantic styles so your XAML asks for a ROLE instead of one design system's specific key, and Semantic Design Tokens so the spacing, shapes, and sizing behind those styles live in one predictable place. You write `FilledButtonStyle` or `BodyLarge`, and the active theme fills in the specifics. Swap `MaterialTheme` for `SimpleTheme` and that same markup comes out looking like a completely different app.

The best part is that none of this is hypothetical. It's all shipping in Uno Themes 7.x today, ready to use. In [Part 2]({% post_url 2026-10-04-uno-themes-8-runtime-seed-colors %}) we'll build on it and get to the 8.0 fun stuff: knobs that reach your controls at runtime, swapping the whole app's font from a single root, and seed colors that stay true to your brand and repaint live. See you there.

Hope you learned something and I'll catch you in the next one :wave:

## Further Reading

- [Semantic Design in Uno Themes - Part 2]({% post_url 2026-10-04-uno-themes-8-runtime-seed-colors %})
- [Uno Themes Overview][themes-overview-docs]
- [Semantic Styles][semantic-styles-docs]
- [Semantic Design Tokens][design-tokens-docs]
- [Uno Simple: Getting Started][simple-getting-started-docs]
- [ThemeStudio on GitHub][theme-studio]

[themes-overview-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/themes-overview.html
[simple-getting-started-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/simple-getting-started.html
[semantic-styles-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/semantic-styles.html
[design-tokens-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/design-tokens.html
[theme-studio]: https://github.com/kazo0/ThemeStudio
[base-theme-scale-gen-gh]: https://github.com/unoplatform/Uno.Themes/blob/e37f7aea988b85d43d04ede7f86e102dc4dc5171/src/library/Uno.Themes/BaseTheme.ScaleGeneration.cs
{% include links.md %}
