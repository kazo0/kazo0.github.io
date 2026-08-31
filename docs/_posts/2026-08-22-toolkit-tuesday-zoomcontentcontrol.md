---
title: "Toolkit Tuesdays: ZoomContentControl"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, zoomcontentcontrol, zoom, pan, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][toolkit-homepage] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-homepage]. I hope you find them useful too!

This week we're covering the `ZoomContentControl`, the Toolkit's answer to a problem that shows up more often than you'd think: "I have some content that's bigger than the space I've got, and I want to let the user zoom into it and move around."

As always, these components need a little extra setup since they're part of the Uno Toolkit library. You can refer to the [Getting Started documentation][uno-toolkit-docs] to get everything wired up.
{: .notice--info}

<!-- TODO: screen recording of the ZoomContentControl demo (zoom in/out + pan) -> /assets/images/zoomcontentcontrol/zoom-demo.mp4 -->

## The Problem

Say you've got a big, detailed image. A floor plan, a schematic, a map, a scanned document, a giant chart. Whatever it is, it doesn't fit on screen at full size, and shrinking it down to fit makes it useless because nobody can read the details. We've all shipped that screen where the user squints and pinches at a blurry blob and quietly hates you for it.

The instinct is to reach for a `ScrollViewer`, and a `ScrollViewer` will happily let you scroll around content that's bigger than the viewport. It even has `ZoomMode`, `MinZoomFactor`, and `MaxZoomFactor` properties inherited from WinUI, so you'd be forgiven for thinking you're done. The trouble is that the built-in zoom story leans on pinch gestures and doesn't give you a clean, consistent way to drive the zoom level from code across every platform Uno targets. The moment you want a "Zoom In" button, a "Reset" button, or a "fit this to the screen" behavior, you're back to writing a pile of plumbing yourself.

That plumbing is exactly what the `ZoomContentControl` hands you for free.

## Anatomy of a `ZoomContentControl`

At its core, the `ZoomContentControl` is a `ContentControl`. You drop it into your XAML, give it some `Content`, and it takes over the job of scaling and translating that content within its own bounds:

<!-- TODO: annotated screenshot of ZoomContentControl showing viewport + zoomed content -> /assets/images/zoomcontentcontrol/anatomy.png -->

1. The viewport, which is the fixed-size area the control occupies in your layout
2. The content, which is whatever you put inside, scaled and panned within the viewport

Under the hood it isn't a real `ScrollViewer` at all. It simulates one using a `ScaleTransform` (that's your `ZoomLevel`) and a `TranslateTransform` (that's your pan offset), then draws its own scroll bars on top. That detail matters because it's why the zoom behaves identically whether you're on Windows, WebAssembly, or a Skia desktop head. No per-platform "why does this feel weird on WASM" rabbit holes, which I've been down more than once.

## Getting Started

Add the `utu` namespace and wrap your content:

```xml
xmlns:utu="using:Uno.Toolkit.UI"
...

<utu:ZoomContentControl MinZoomLevel="0.5"
                        MaxZoomLevel="4">
    <Image Source="ms-appx:///Assets/large-map.png"
           Stretch="Uniform" />
</utu:ZoomContentControl>
```

That's genuinely all it takes to get something zoomable. No code-behind, no gesture wrangling, nothing. :ok_hand:

Out of the box you get these interactions on desktop:

- **Ctrl + Mouse Wheel** zooms in and out, centered on the cursor
- **Mouse Wheel** scrolls vertically; **Shift + Mouse Wheel** scrolls horizontally
- **Middle-click + drag** pans the content

For any of that to work, the control needs to be loaded and visible, `IsActive` needs to be `true` (it is by default), and the relevant `IsZoomAllowed` / `IsPanAllowed` flags need to be `true` (also both default to `true`).
{: .notice--info}

A quick note on expectations, because I don't want you to be surprised: the built-in interactions above are mouse- and keyboard-driven. There's no automatic pinch-to-zoom or double-tap gesture baked in, so if you're targeting touch you'll want to drive the `ZoomLevel` yourself with some buttons. Which, conveniently, is exactly what we're about to do.
{: .notice--warning}

## Controlling the Zoom From Code

The most useful thing about this control is that `ZoomLevel` is just a plain `double` dependency property. Want a "Zoom In" button? Nudge the number:

```xml
<StackPanel>
    <utu:ZoomContentControl x:Name="ZoomContent"
                            Width="400"
                            Height="300"
                            ZoomLevel="1"
                            MinZoomLevel="0.5"
                            MaxZoomLevel="10"
                            IsZoomAllowed="True"
                            IsPanAllowed="True">
        <Border BorderBrush="White"
                BorderThickness="2"
                Padding="10">
            <Image Source="ms-appx:///Assets/UnoLogo.png"
                   Width="75"
                   Height="101" />
        </Border>
    </utu:ZoomContentControl>

    <StackPanel Orientation="Horizontal"
                Spacing="12"
                HorizontalAlignment="Center">
        <Button x:Name="ZoomInButton" Content="Zoom In" />
        <Button x:Name="ZoomOutButton" Content="Zoom Out" />
        <Button x:Name="ResetButton" Content="Reset" />
    </StackPanel>
</StackPanel>
```

And the code-behind is about as simple as it gets:

```csharp
private void OnZoomInClick(object sender, RoutedEventArgs e)
{
    if (ZoomContent.ZoomLevel < ZoomContent.MaxZoomLevel)
    {
        ZoomContent.ZoomLevel += 0.2;
    }
}

private void OnZoomOutClick(object sender, RoutedEventArgs e)
{
    if (ZoomContent.ZoomLevel > ZoomContent.MinZoomLevel)
    {
        ZoomContent.ZoomLevel -= 0.2;
    }
}

private void OnResetClick(object sender, RoutedEventArgs e)
{
    ZoomContent.ResetViewport();
}
```

<!-- TODO: screen recording of the button-driven zoom in/out/reset -> /assets/images/zoomcontentcontrol/buttons.mp4 -->

And that's the whole trick. Notice I'm checking against `MinZoomLevel` and `MaxZoomLevel` before nudging the value. The control will happily clamp things for you, but guarding the button logic keeps the intent obvious for whoever reads this next (usually me, six months from now, having forgotten I wrote it). If you're doing this in an MVVM or MVUX app, `ZoomLevel` binds just as happily to a view model property.

## The Helper Methods

That `ResetButton` above calls `ResetViewport()`, which is one of a handful of convenience methods the control exposes. Here's the full set and what each one actually does:

| Method            | What it does                                                 |
| ----------------- | ------------------------------------------------------------ |
| `ResetZoom()`     | Sets `ZoomLevel` back to `1`                                 |
| `ResetScroll()`   | Resets the scroll/pan position to `(0, 0)`                   |
| `ResetViewport()` | Does both of the above, back to 100% and re-centered         |
| `CenterContent()` | Centers the content within the viewport                      |
| `FitToCanvas()`   | Adjusts `ZoomLevel` so the content fills the available space |

`FitToCanvas()` is the one I reach for most. If you've got a document or a diagram and you want the classic "fit to page" behavior, that's your button. And if you'd rather it happen automatically whenever the content or viewport size changes? You don't even need the button, as we'll see next.

## Auto-Fit and Auto-Center

Two boolean properties handle the automatic cases:

```xml
<utu:ZoomContentControl AutoFitToCanvas="True"
                        AutoCenterContent="True">
    <Image Source="ms-appx:///Assets/large-map.png" />
</utu:ZoomContentControl>
```

- `AutoFitToCanvas` (defaults to `false`) calls `FitToCanvas()` for you whenever the content or viewport resizes, so your content always starts out fully visible
- `AutoCenterContent` (defaults to `true`) keeps the content centered in the viewport

That's a lovely pairing for something like an image viewer that should always open showing the whole image, then let the user zoom in from there. Two properties, zero code-behind. I'll take it.

## Fine-Tuning the Feel

A few more properties let you dial in the experience:

- **`ScaleWheelRatio`** controls how much the zoom factor changes per mouse wheel tick. It's a small number by default (`0.0006`), so if scrolling feels too slow or too twitchy, this is your knob.
- **`PanWheelRatio`** does the same thing for how far a wheel tick pans (defaults to `0.25`).
- **`AdditionalMargin`** adds an unscaled `Thickness` of breathing room around the content, so you can pan a little past the edges instead of having the content jammed right up against the viewport border.
- **`AllowFreePanning`** (defaults to `true`) lets the content be panned outside the viewport bounds rather than being locked in.
- **`ScrollBarLayout`** lets you change how the simulated scroll bars are laid out.

None of these are required reading (the defaults are sensible), but they're there when you need to make the interaction feel right for your particular content.

## Focusing on a Specific Element

The last property worth calling out is `ElementOnFocus`. Point it at a child `FrameworkElement` and the control's auto-zoom and auto-fit behavior will center around *that* element rather than the content as a whole. There's a matching `SetLocalFocus(...)` / `ClearLocalFocus()` pair in code if you want to drive it dynamically, which is handy for something like "zoom to this node in a diagram" where the focus target changes as the user clicks around.

## A Note on the Docs

One heads-up if you go digging through the reference material, because it tripped me up: an older how-to snippet mentions `ZoomTo(...)` and `ZoomToRect(...)` methods. Those aren't part of the control as it ships today, so don't go hunting for them like I did. Set the `ZoomLevel` property directly (or use `FitToCanvas()` / `ResetViewport()`) and you'll get where you're going. I've flagged it so the docs can catch up.
{: .notice--warning}

## Conclusion

The `ZoomContentControl` is one of those controls that looks small but quietly saves you a real chunk of work. Any time you've got content that's bigger than the space you can give it (maps, floor plans, schematics, big images, documents), this is the thing that turns it into a proper zoom-and-pan experience, with a `ZoomLevel` you can bind and a set of reset/fit helpers that cover the common buttons you'd otherwise be writing by hand.

You can play with it right now in the [Uno Toolkit Samples app][toolkit-samples], which has a live `ZoomContentControl` page you can poke at across every platform.

I hope you enjoyed this edition of Toolkit Tuesdays! As always, I encourage you to consult the full documentation using the links below, and to jump into the fun on the [Uno Toolkit GitHub repo][uno-toolkit] if you find a bug, want to make an improvement, or want to help the docs along.

## Further Reading

- [ZoomContentControl Docs][zoomcontentcontrol-docs]
- [Uno Toolkit Docs][uno-toolkit-docs]

[zoomcontentcontrol-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/ZoomContentControl.html
[toolkit-samples]: https://github.com/unoplatform/uno.toolkit.ui/tree/main/samples
{% include links.md %}
