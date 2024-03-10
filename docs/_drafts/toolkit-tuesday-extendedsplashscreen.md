---
title: "Toolkit Tuesdays: ExtendedSplashScreen"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, splash, splashscreen, extendedsplashscreen, splash-screen, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][toolkit-homepage] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-homepage]. I hope you find them useful too!

This week we are covering the `ExtendedSplashScreen` control. This control can be used to prolong the display of the native platform's splashscreen while your app continues to load. Not only that, it also enables you to overlay the extended splashscreen with custom content such as a `ProgressRing` and/or custom branding. This is a great way to provide a more seamless experience to your users while your app is loading.

As always, these components require some extra setup since they are part of the Uno Toolkit library. You can refer to the [Getting Started documentation][uno-toolkit-docs] in order to get everything set up and ready to go.
{: .notice--info}

## Anatomy of `ExtendedSplashScreen`

### Android

![](/assets/images/extsplash/android-splash.gif){: .width-half}

### WASM

![](/assets/images/extsplash/wasm-splash.gif)

You can imagine the `ExtendedSplashScreen` as three separate layers:

1. **Native Splashscreen Content**: This is the splashscreen that is displayed by the native platform (iOS, Android, WASM, etc.) when your app is launched. This is the first thing that your users will see when they launch your app.
2. **Loading Content**: This is the splashscreen that is displayed by the `ExtendedSplashScreen` control. This is displayed after the native splashscreen and is used to prolong the display of the splashscreen while your app continues to load. This is the second thing that your users will see when they launch your app.
3. **App Content**: This is the custom content that you can overlay on top of the `ExtendedSplashScreen`. This can be anything you want, such as a `ProgressRing` or custom branding. This is the third thing that your users will see when they launch your app.

`SafeArea` is built on top of Uno Platform's cross-platform implementation of the [`ApplicationView.VisibleBounds` API from WinUI][visible-bounds-winui]. This API returns the bounds within the app window that are not occluded by any system UI or display cutouts. `SafeArea` compares the `VisibleBounds` to the bounds of the specified control and calculates the insets needed to ensure that the control is not obscured.

By default, `SafeArea` will attempt to apply the calculated insets to the `Padding` of the specified control. This behavior can be changed by setting the `Mode` property to `InsetMode.Margin` instead. Additionally, through the `Insets` property, you can specify which sides of the `SafeArea` should be taken into consideration when calculating the insets.

## Properties

<div class="notice--primary" markdown="1">
**Note:** `SafeArea` can be used as a control or as a set of attached properties on another `FrameworkElement`, much like the `ScrollViewer`:

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

</div>

### Insets

The `Insets` property determines which sides of the `SafeArea` should be considered when calculating the insets. The default value is `InsetMask.None`.

|Options|
|---|
|`None`|
|`Left`|
|`Top`|
|`Right`|
|`Bottom`|
|`SoftInput`|
|`VisibleBounds` = `Left`, `Top`, `Right`, `Bottom`|
|`All` = `VisibleBounds`, `SoftInput`|

`SoftInput` is used to ensure that the specified area will adapt to any sort of soft-input panel that may appear, such as the on-screen keyboard on touch devices. More on this [later](#softinput-example).
{: .notice--info}

### Mode

The `Mode` property is used by the `SafeArea` to determine how the insets should be applied to a control that is in an "unsafe" area. The default value is `InsetMode.Padding`.

|Options|
|---|
|`Padding`|
|`Margin`|

## Examples

Let's see it in action and jump into some code!

**Note:** I'll be using iOS for my example screenshots going forward, but the same concepts apply to Android. This is mostly to make my life easier and not have to take screenshots on multiple devices. Also, the `SafeArea` is most useful on iOS because of the notch and the home indicator. Android tends to prevent your content from flowing beneath the system UI by default. This behaviour can be altered by using the [windowTranslucentStatus](https://developer.android.com/reference/android/R.attr#windowTranslucentStatus) and [windowTranslucentNavigation](https://developer.android.com/reference/android/R.attr#windowTranslucentNavigation) system flags.
{: .notice--warning}

Let's start with the example XAML that was used for the [Anatomy section](#anatomy-of-safearea) above:

```xml
<Page x:Class="SafeAreaApp.MainPage"
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:local="using:SafeAreaApp"
      xmlns:utu="using:Uno.Toolkit.UI"
      Background="Yellow">
    <Grid Background="Purple">
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
</Page>
```

Notice the blue `Grid` containing the "Top Area" `TextBlock` is beneath the status bar text and is being obscured by the Dynamic Island area of the iPhone 15:

![Unsafe Top](/assets/images/safearea/safearea-unsafe-top.png)

As well as the blue `Grid` containing the "Bottom Area" `TextBlock` being obscured by the Home Indicator:

![Unsafe Bottom](/assets/images/safearea/safearea-unsafe-bottom.png)

As a first pass to avoid this issue, let's try setting the `SafeArea.Insets` attached property on the main purple `Grid` to `Top,Bottom`:

```diff
...
<Grid Background="Purple"
+     utu:SafeArea.Insets="Top,Bottom">
...
```

Now we see that the "Top Area" `TextBlock` is no longer being obscured and is visible beneath the status bar:

![Safe Top](/assets/images/safearea/safearea-safe-top.png)

We also see that the "Bottom Area" `TextBlock` is no longer obscured and is visible above the Home Indicator:

![Safe Bottom](/assets/images/safearea/safearea-safe-bottom.png)

Much better!

We can see that the `SafeArea` is doing its job and properly applying a `Padding` to the purple `Grid` so that any content inside of the `Grid` will be "inset" from the "unsafe" areas of the screen.

What happens if we were to set the `SafeArea.Mode` to `InsetMode.Margin` instead?

```diff
...
<Grid Background="Purple"
+     utu:SafeArea.Mode="Margin"
      utu:SafeArea.Insets="Top,Bottom">
...
```

Top|Bottom
:-:|:-:
![Top SafeArea with Margin](/assets/images/safearea/safearea-safe-margin-top.png)|![Bottom SafeArea with Margin](/assets/images/safearea/safearea-safe-margin-bottom.png)

:open_mouth: Holy Yellow Batman! What happened there?

Well, the `SafeArea` is still doing its job but now it's applying a `Margin` to the purple `Grid` instead of a `Padding`. This means that the purple `Grid` is now being pushed down and up by the `SafeArea` insets. If you look back at the original XAML for the `Page`, you'll see that we had set a `Background` of `Yellow` on the `Page`. This is why we see the yellow background of the `Page` showing through.

I'm not a huge fan of this look, nor do I like the look of the previous `Padding` approach. I think it looks better when the content is allowed to "bleed" into the unsafe areas and is flush with the top and bottom of the screen. Let's try something else.

```diff
+ <Grid Background="Purple">
-       utu:SafeArea.Mode="Margin"
-       utu:SafeArea.Insets="Top,Bottom">
    <Grid VerticalAlignment="Top"
+         utu:SafeArea.Insets="Top"
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
+         utu:SafeArea.Insets="Bottom"
          Background="Blue">
        <TextBlock Text="Bottom Area"
                   FontSize="30"
                   VerticalAlignment="Center"
                   HorizontalAlignment="Center" />
    </Grid>
 </Grid>
```

We are going to remove the `SafeArea` attached property setters from the main purple `Grid` and instead apply them to the "Top Area" and "Bottom Area" `Grid`s. Notice two things here:

1. The `SafeArea.Insets` attached property is now set to `Top` for the "Top Area" `Grid` and `Bottom` for the "Bottom Area" `Grid`
2. The `SafeArea.Mode` attached property is not set on either `Grid`, so it defaults to `Padding`.

Top|Bottom
:-:|:-:
![Top SafeArea Grid](/assets/images/safearea/safearea-safe-grid-top.png)|![Bottom SafeArea Grid](/assets/images/safearea/safearea-safe-grid-bottom.png)

Looking good!

Now we have both the top and the bottom `Grid` areas being inset from the unsafe areas using their `Padding`. This allows for the background of each `Grid` to show through and gives the appearance that the container is bleeding into the unsafe areas while still ensuring that the actual content is not obscured.

So that's it, right? We'll always be able to see our content no matter what, right?...

RIGHT?!?!

Let's make a small tweak to our UI and see what happens:

```diff
<Grid Background="Purple">
    <Grid VerticalAlignment="Top"
          utu:SafeArea.Insets="Top"
          Background="Blue">
        <TextBlock Text="Top Area"
                   FontSize="30"
                   VerticalAlignment="Center"
                   HorizontalAlignment="Center" />
    </Grid>
-   <TextBlock Text="Hello, world!"
+   <TextBox PlaceholderText="Hello, world!"
             FontSize="30"
             VerticalAlignment="Center"
             HorizontalAlignment="Center" />
    <Grid VerticalAlignment="Bottom"
          utu:SafeArea.Insets="Bottom"
          Background="Blue">
        <TextBlock Text="Bottom Area"
                   FontSize="30"
                   VerticalAlignment="Center"
                   HorizontalAlignment="Center" />
    </Grid>
 </Grid>
```

Let's see what happens now if we were to focus on this new `TextBox` and toggle the keyboard:

![SafeArea with keyboard opening](/assets/images/safearea/safearea-kb-unsafe.gif){: .align-center}

Uh oh!

Our bottom content is now being obscured by the keyboard. This may not be a huge deal in this example, but it could be a big deal in your app. You may have content that you would like to be visible at all times, such as a "Send" button or a "Cancel" button. Let's see what we can do about this.

### SoftInput Example

The `SafeArea.Insets` property has a special `InsetMask` value called `SoftInput`. This value is used to ensure that the specified area will adapt to any sort of soft input panel that may appear, such as the on-screen keyboard on touch devices. Let's try it out!

```diff
 <Grid Background="Purple">
    <Grid VerticalAlignment="Top"
          utu:SafeArea.Insets="Top"
          Background="Blue">
        <TextBlock Text="Top Area"
                   FontSize="30"
                   VerticalAlignment="Center"
                   HorizontalAlignment="Center" />
    </Grid>
    <TextBox PlaceholderText="Hello, world!"
             FontSize="30"
             VerticalAlignment="Center"
             HorizontalAlignment="Center" />
    <Grid VerticalAlignment="Bottom"
-         utu:SafeArea.Insets="Bottom"
+         utu:SafeArea.Insets="Bottom,SoftInput"
          Background="Blue">
        <TextBlock Text="Bottom Area"
                   FontSize="30"
                   VerticalAlignment="Center"
                   HorizontalAlignment="Center" />
    </Grid>
 </Grid>
```

Now, when we focus on the `TextBox` and toggle the keyboard, we see that the bottom content is no longer being obscured:

![SafeArea with keyboard opening using SoftInput](/assets/images/safearea/safearea-kb-safe.gif){: .align-center}

In fact, if you look closely, you'll notice that the entire area beneath the keyboard panel has become blue. This is because the `SafeArea` is now applying a `Padding` to the bottom `Grid` that is equal to the height of the keyboard panel. This ensures that the bottom content will always be visible. `SafeArea` basically treats the keyboard area as "unsafe" for any control that has the `InsetMask.SoftInput` applied.

**Warning:** The usage of `SoftInput` is a more advanced use case and comes with some caveats. Using `SoftInput` should usually be paired with the usage of a `ScrollViewer`. More information can be found in the [official SafeArea documentation][safearea-docs-softinput].
{: .notice--warning}

## Conclusion

Notice how I didn't include my face in the example screenshots this time? :stuck_out_tongue_winking_eye:

Let's add one here, just for good measure:

![Me](/assets/images/profile.png){: .align-center .width-half}

If you want to take a look at the full source code for the examples above, you can find it on this [GitHub repo][safearea-sample-gh].

I hope you enjoyed this edition of Toolkit Tuesdays! There is even more to learn about `SafeArea` so I hope you will continue to explore it on your own.

I encourage you to consult the full documentation for `SafeArea` using the links below. I also want to welcome you to contribute to making `SafeArea` even better! Whether you have discovered some bugs, want to make improvements, or want to enhance the documentation, please jump into the fun on the [Uno Toolkit GitHub repo][uno-toolkit]!

## Further Reading

- [SafeArea Docs][safearea-docs]
- [Uno Toolkit Docs][uno-toolkit-docs]

[safearea-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/SafeArea.html
[uno-toolkit-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/getting-started.html
[visible-bounds-winui]: https://learn.microsoft.com/en-us/uwp/api/windows.ui.viewmanagement.applicationview.visiblebounds
[attached-docs]: https://learn.microsoft.com/en-us/windows/uwp/xaml-platform/custom-attached-properties
[safearea-sample-gh]: https://github.com/kazo0/SafeAreaApp
[safearea-docs-softinput]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/SafeArea.html?tabs=none#using-insetmasksoftinput-for-on-screen-keyboards
[net-advent]: https://dotnet.christmas/
{% include links.md %}