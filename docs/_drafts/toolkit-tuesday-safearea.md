---
title: "Toolkit Tuesdays: SafeArea"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, safearea, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][uno-toolkit] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-repo]. I hope you find them useful too!

This week we are covering the `SafeArea` component. `SafeArea` comes packaged as both a specialized control and as a set of attached properties. The purpose of `SafeArea` is to ensure that your content is never obscured by certain system UI elements or hardware display cutouts.

## Anatomy of `SafeArea`

iOS|Android
:-:|:-:
![](/assets/images/safearea/safearea-ios.gif)|![](/assets/images/safearea/safearea-android.gif)

The above example depicts the difference in layout when using `SafeArea` on iOS and Android for the following XAML:

```xml
<!-- SafeArea Usage: -->
<Grid Background="Purple"
      utu:SafeArea.Insets="VisibleBounds">
    <Grid VerticalAlignment="Top"
            Background="Blue">
        <TextBlock Text="Top Area"
                    FontSize="30"
                    VerticalAlignment="Center"
                    HorizontalAlignment="Center" />
    </Grid>
    <TextBlock Text="Hello, world!"
                FontSize="30"
                VerticalAlignment="Center"
                HorizontalAlignment="Center" />
    <Grid VerticalAlignment="Bottom"
          Background="Blue">
        <TextBlock Text="Bottom Area"
                    FontSize="30"
                    VerticalAlignment="Center"
                    HorizontalAlignment="Center" />
    </Grid>
</Grid>
```

`SafeArea` is built on top of Uno Platform's cross-platform implementation of the [`ApplicationView.VisibleBounds` API from WinUI](visible-bounds-winui). This API returns the bounds within the app window that are not occluded by any system UI or display cutouts. `SafeArea` compares the `VisibleBounds` to the bounds of the specified control and calculates the insets needed to ensure that the content is not obscured. 

By default, `SafeArea` will apply the insets to the `Padding` of the specified control. This behavior can be changed by setting the `InsetMode` to `Margin` instead. You are also able to specify the edges of the control that are affected by `SafeArea` through the `Insets` property.

## Properties

**NOTE:** `SafeArea` can be used as a control or as a set of attached properties on another `FrameworkElement`, much like the `ScrollViewer`:
{: .notice--info}

```xml
xmlns:utu="using:Uno.Toolkit.UI"

<!-- as attached property on another FrameworkElement -->
<Grid utu:SafeArea.Insets="Left,Top,Right,Bottom">
    <!-- Content -->
</Grid>

<!-- or, as a control -->
<utu:SafeArea Insets="Left,Top,Right,Bottom">
    <!-- Content -->
</utu:SafeArea>
```

### Insets

The `Insets` property determines which edges of the `SafeArea` should be considered when calculating the insets. The default value is `None`.

- `Left`
- `Top`
- `Right`
- `Bottom`
- `SoftInput`
- `VisibleBounds` = `Left`, `Top`, `Right`, `Bottom`
- `All` = `VisibleBounds`, `SoftInput`

`SoftInput` is used to ensure that the specified area will adapt to any sort of soft-input panel that may appear, such as the on-screen keyboard on touch devices. More on this later.
{: .notice--info}

### `Background`

The `Background` property is more straightforward and can be set to any color. It should be noted that, due to platform limitations, only `SolidColorBrush` is supported.

## Examples

Let's see it in action and jump into some code! Get ready to see my face plastered all over the place once again.

**Note:** I'll be using iOS for my example screenshots going forward, but the same concepts apply to Android. This is mostly to make my life easier and not have to take screenshots on multiple devices.
{: .notice--info}

**Attention!** On iOS, `UIViewControllerBasedStatusBarAppearance` should be set to false in your `Info.plist`.
{: .notice--warning}

Let's start with a basic page that sets the StatusBar to some sexy Uno Platform colors.

First things first, let's get some colors and brushes defined as well as the Uno Toolkit resources loaded in our `AppResources.xaml`:

```xml
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">

    <ResourceDictionary.MergedDictionaries>
        <!-- Load WinUI resources -->
        <XamlControlsResources xmlns="using:Microsoft.UI.Xaml.Controls" />
        <!-- Load Uno.UI.Toolkit resources -->
        <ToolkitResources xmlns="using:Uno.Toolkit.UI" />
    </ResourceDictionary.MergedDictionaries>

    <Color x:Key="UnoBlue">#FF229DFC</Color>
    <Color x:Key="UnoPurple">#FF7A69F5</Color>
    <Color x:Key="UnoGreen">#FF6CE5AE</Color>
    <Color x:Key="UnoRed">#FFF65678</Color>

    <SolidColorBrush x:Key="UnoBlueBrush" Color="{StaticResource UnoBlue}" />
    <SolidColorBrush x:Key="UnoPurpleBrush" Color="{StaticResource UnoPurple}" />
    <SolidColorBrush x:Key="UnoGreenBrush" Color="{StaticResource UnoGreen}" />
    <SolidColorBrush x:Key="UnoRedBrush" Color="{StaticResource UnoRed}" />
</ResourceDictionary>
```

Now, we can use one of those brushes as the background for our status bar:

```xml
<Page x:Class="StatusBarApp.MainPage"
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:utu="using:Uno.Toolkit.UI"
      utu:StatusBar.Foreground="Auto"
      utu:StatusBar.Background="{StaticResource UnoPurpleBrush}"
      Background="{StaticResource UnoBlueBrush}">
    <Image Width="200"
           Height="200"
           Margin="16"
           VerticalAlignment="Top"
           Source="ms-appx:///StatusBarApp/Assets/Images/steve.png" />
</Page>
```

![Purple Status Bar](/assets/images/statusbar/statusbar-purple-auto.png)

I kinda hate the look of the default dark text on the Purple background so let's change that to light text:

```diff
...
      xmlns:utu="using:Uno.Toolkit.UI"
-     utu:StatusBar.Foreground="Auto"
+     utu:StatusBar.Foreground="Light"
      utu:StatusBar.Background="{StaticResource UnoPurpleBrush}"
...
```

![Purple Status Bar with Light text](/assets/images/statusbar/statusbar-purple-light.png)

Much better! This way the text will always be White, regardless of the theme. Which is fine because our background is always going to be the Uno Purple color.

But what if we wanted to have our status bar change colors based on the theme? Let's try that out!

First, let's define some new brushes in our `AppResources.xaml` that change values based on the theme:

```xml
<ResourceDictionary.ThemeDictionaries>
    <ResourceDictionary x:Key="Light">
        <SolidColorBrush x:Key="MyStatusBarBackground" Color="BlanchedAlmond" />
    </ResourceDictionary>
    <ResourceDictionary x:Key="Dark">
        <SolidColorBrush x:Key="MyStatusBarBackground" Color="SaddleBrown" />
    </ResourceDictionary>
</ResourceDictionary.ThemeDictionaries>
```

And use that new brush as the background for our status bar:

```diff
...
      xmlns:utu="using:Uno.Toolkit.UI"
      utu:StatusBar.Foreground="Light"
-     utu:StatusBar.Background="{StaticResource UnoPurpleBrush}"
+     utu:StatusBar.Background="{ThemeResource MyStatusBarBackground}"
...
```

Light|Dark
:-:|:-:
![StatusBar with BlanchedAlmond background and Light foreground](/assets/images/statusbar/statusbar-almond-light.png)|![StatusBar with SaddleBrown background and Light foreground](/assets/images/statusbar/statusbar-brown-dark.png)

Hmm, having a `utu:StatusBar.Background` of `Light` doesn't look good anymore, especially when the app is in light mode. Let's change that back to `Auto`:

```diff
...
      xmlns:utu="using:Uno.Toolkit.UI"
-     utu:StatusBar.Foreground="Light"
+     utu:StatusBar.Foreground="Auto"
      utu:StatusBar.Background="{ThemeResource MyStatusBarBackground}"
...
```

Light|Dark
:-:|:-:
![StatusBar with BlanchedAlmond background and Auto foreground](/assets/images/statusbar/statusbar-almond-auto.png)|![StatusBar with SaddleBrown background and Auto foreground](/assets/images/statusbar/statusbar-brown-auto.png)

Looking good! Now we have a status bar that changes background colors based on the theme and the text color changes to match the theme as well. Notice that the dark theme screenshot looks the same as before. This is because we set the `utu:StatusBar.Foreground` to `Auto` and the system automatically uses White as the text when in dark mode.

Now, what if we wanted to invert the background colors and instead use `SaddleBrown` when we are in Light mode and `BlanchedAlmond` when we are in Dark mode? Let's try that out!

```diff
<ResourceDictionary.ThemeDictionaries>
    <ResourceDictionary x:Key="Light">
-       <SolidColorBrush x:Key="MyStatusBarBackground" Color="BlanchedAlmond" />
+       <SolidColorBrush x:Key="MyStatusBarBackground" Color="SaddleBrown" />
    </ResourceDictionary>
    <ResourceDictionary x:Key="Dark">
-       <SolidColorBrush x:Key="MyStatusBarBackground" Color="SaddleBrown" />
+       <SolidColorBrush x:Key="MyStatusBarBackground" Color="BlanchedAlmond" />
    </ResourceDictionary>
</ResourceDictionary.ThemeDictionaries>
```

Light|Dark
:-:|:-:
![StatusBar with SaddleBrown background and Auto foreground](/assets/images/statusbar/statusbar-brown-auto-light.png)|![StatusBar with BlanchedAlmond background and Auto foreground](/assets/images/statusbar/statusbar-almond-auto-dark.png)

Yuck :nauseated_face:

This doesn't seem to work very well with the `Auto` foreground. Let's try setting the foreground to `AutoInverse` instead:

```diff
...
      xmlns:utu="using:Uno.Toolkit.UI"
-     utu:StatusBar.Foreground="Auto"
+     utu:StatusBar.Foreground="AutoInverse"
      utu:StatusBar.Background="{ThemeResource MyStatusBarBackground}"
...
```

Light|Dark
:-:|:-:
![StatusBar with SaddleBrown background and AutoInverse foreground](/assets/images/statusbar/statusbar-brown-dark.png)|![StatusBar with BlanchedAlmond background and AutoInverse foreground](/assets/images/statusbar/statusbar-almond-auto.png)

The `AutoInverse` value is exactly what we need! Now the text color will always be White in Light mode and Black in Dark mode.

## Conclusion

I'm sure you're sick of seeing my dumb smiling face staring into your soul with every screenshot so I will wrap this up and point you to some resources for more information.

I encourage you to consult the full documentation for `StatusBar` using the links below. I also want to welcome you to contribute to making `StatusBar` even better! Whether you have discovered some bugs, want to make improvements, or want to enhance the documentation, please jump into the fun on the [Uno Toolkit GitHub repo][uno-toolkit]!

## Further Reading

- [StatusBar Docs][statusbar-docs]
- [Uno Toolkit Docs][uno-toolkit-docs]

[safearea-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/StatusBar-extensions.html
[uno-toolkit-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/getting-started.html
[visible-bounds-winui]: https://learn.microsoft.com/en-us/uwp/api/windows.ui.viewmanagement.applicationview.visiblebounds?view=winrt-22621
[attached-docs]: https://learn.microsoft.com/en-us/windows/uwp/xaml-platform/custom-attached-properties
{% include links.md %}