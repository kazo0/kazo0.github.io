---
title: "Uno Tidbit: Extending Your Resources"
category: uno-tidbit
header:
  teaser: /assets/images/tidbit-hero.png
  og_image: /assets/images/tidbit-hero.png
tags: [uno-tidbits, uno-tidbit, tidbit, resources, staticresource, resourcedictionary, uno-platform, uno, unoplatform]
---

Welcome to another edition of Uno Tidbits! In this series, we will be covering small, bite-sized topics that are useful to know when working with Uno Platform. These will be quick reads that you can consume in a few minutes and will cover a wide range of topics. Today, we are going to cover how you can do more with your `ResourceDictionary` in Uno Platform.

{% include video id="OwQkYSlowfU" provider="youtube" %}

## The Problem

Ever wanted to make a slight modification to a control's appearance only to find out that there's no public property to drive that change? Maybe you want to change the color of a `Button` when it's disabled, or you want to change the foreground color of a `TextBox` when it's focused. These changes would be buried deep in the control's template, perhaps as part of the beautiful mess that is the `VisualStateManager`.

## The Solution?

Good news! There already exists a half-baked solution for you!

Thanks to [Lightweight Styling][ms-lightweight-styling] you have the ability to override resources that are referenced in a control's template. These overrides can be scoped to a specific control, a page, or even the entire app.

Now what if you wanted to include those overrides for specific instances of the control across your app? What if you wanted to package up these overrides into a reusable style that you could apply anywhere you want?

Well, now you're just getting greedy.

## The REAL Solution

Luckily for you, I am also greedy and I have a solution for you!

Ideally, we would be able to package up any resource overrides as part of a custom `Style`. Unfortunately, the `Resources` property of a `FrameworkElement` is not a `DependencyProperty` and, therefore, cannot be set using a `Style.Setter`.

This is where the [Uno Toolkit][uno-toolkit-repo] comes in! Within the Uno Toolkit, there is a [`ResourceExtension`][resource-ext-toolkit] class that provides a `Resources` Attached Property that forwards the provided `ResourceDictionary` to the `FrameworkElement.Resources` but comes with all of that `DependencyProperty` goodness. This allows you to package up your resource overrides into a `ResourceDictionary` and use it within a `Setter` of a `Style`.

## Example

Let's say you want to edit some of the `Button` styles from [Uno Material][uno-material-gh]. You might have a specific flow or section in your app that requires a different color for the `Button` when it's at rest and when it's in the PointerOver state. Your favorite colors just happen to be `CornflowerBlue` and `LightSeaGreen`. Except those clash with the app while it's in Dark Mode. So you want to use `Red` and `Orange` in that case instead. Just go with me here.

You can define your own `Style` based on the `FilledButtonStyle` and use your favorite colors:

```xml
<Style TargetType="Button"
       x:Key="MyCustomButtonStyle"
       BasedOn="{StaticResource FilledButtonStyle}">
    <Setter Property="utu:ResourceExtensions.Resources">
        <Setter.Value>
            <ResourceDictionary>
                <ResourceDictionary.ThemeDictionaries>
                    <ResourceDictionary x:Key="Light">
                        <SolidColorBrush x:Key="FilledButtonBackground" Color="LightSeaGreen" />
                        <SolidColorBrush x:Key="FilledButtonBackgroundPointerOver" Color="CornflowerBlue" />
                    </ResourceDictionary>
                    <ResourceDictionary x:Key="Dark">
                        <SolidColorBrush x:Key="FilledButtonBackground" Color="Red" />
                        <SolidColorBrush x:Key="FilledButtonBackgroundPointerOver" Color="Orange" />
                    </ResourceDictionary>
                </ResourceDictionary.ThemeDictionaries>
            </ResourceDictionary>
        </Setter.Value>
    </Setter>
</Style>
```

![MyCustomButtonStyle in action](/assets/images/res-ext/res-ext-button.gif)

A completely customized button without needing to re-template the control!

## Conclusion

That's it! We now have the ability to package up our resource overrides into a `Style` and apply them anywhere we want.

You can check out a working example of this in the [ResourcesExtensionApp repository][res-ext-gh] on GitHub.

Catch you in the next one :wave:

[ms-lightweight-styling]: https://learn.microsoft.com/en-us/windows/apps/design/style/xaml-styles#lightweight-styling
[resource-ext-toolkit]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/resource-extensions.html
[uno-toolkit-repo]: https://github.com/unoplatform/uno.toolkit.ui
[res-ext-gh]: https://github.com/kazo0/ResourcesExtensionApp
[uno-material-gh]: https://github.com/unoplatform/Uno.Themes/tree/master/src/library/Uno.Material