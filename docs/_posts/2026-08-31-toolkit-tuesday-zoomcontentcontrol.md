---
title: "Toolkit Tuesdays: ZoomContentControl"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, zoomcontentcontrol, zoom, pan, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][toolkit-homepage] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-homepage]. I hope you find them useful too!

This week we're covering a new[^ish] control! The `ZoomContentControl`. The name pretty much explains it: it's a control that lets you zoom and pan whatever content you put inside it. It handles the scaling, the panning, and even draws its own scroll bars, so you can focus on your content instead of the plumbing.

As always, these components need a little extra setup since they're part of the Uno Toolkit library. You can refer to the [Getting Started documentation][uno-toolkit-docs] to get everything wired up.
{: .notice--info}

{% include local-video.html src="/assets/images/zoomcontentcontrol/zoom-demo.mp4" caption="Zooming in, panning around, zooming back out, and fitting to the canvas." %}

Every demo you're about to see comes from a runnable Uno Platform app. If you'd rather poke at the code than read about it, it's all in [kazo0/ZoomContentControlSample][zcc-sample].
{: .notice--info}

## The Problem

Say you've got a big, detailed image. A floor plan, a schematic, a map, a scanned document, a giant chart. Or even just some good old XAML content that you need to display in a limited space. A graphic, a diagram, a complex layout. Whatever it is, you need to zoom it, pan it... bop it, twist it, pull it[^bop-it-yt]

The instinct is to reach for a `ScrollViewer`, and a `ScrollViewer` will happily let you scroll around content that's bigger than the viewport. It even has `ZoomMode`, `MinZoomFactor`, and `MaxZoomFactor` properties inherited from WinUI, so you'd be forgiven for thinking you're done. The trouble is that the built-in zoom doesn't give you a clean, convenient way to drive the zoom level from code. The moment you want a "Zoom In" button, a "Reset" button, or a "fit this to the screen" behavior, you're back to writing a pile of plumbing yourself.

And to be fair to `ScrollViewer`: those zoom APIs recently became real on Uno's Skia targets ([uno#22337](https://github.com/unoplatform/uno/pull/22337), merged July 2026). I rebuilt this whole sample on plain `ScrollViewer` to see how far that gets you. The [plumbing section](#so-why-not-just-a-scrollviewer) below has the receipts.
{: .notice--info}

That plumbing is exactly what the `ZoomContentControl` hands you for free.

## Anatomy of a `ZoomContentControl`

At its core, the `ZoomContentControl` is a `ContentControl`. You drop it into your XAML, give it some `Content`, and it takes over the job of scaling and translating that content within its own bounds:

1. The viewport, which is the fixed-size area the control occupies in your layout
2. The content, which is whatever you put inside, scaled and panned within the viewport

<figure>
  <img src="/assets/images/zoomcontentcontrol/anatomy.png" alt="A ZoomContentControl with the viewport bounds and the scaled content annotated">
  <figcaption>The two things to keep straight: the viewport stays put, the content scales and pans inside it.</figcaption>
</figure>

Under the hood it isn't a real `ScrollViewer` at all. It simulates one using a `ScaleTransform` (that's your `ZoomLevel`) and a `TranslateTransform` (that's your pan offset), then draws its own scroll bars on top.

And because it's a `ContentControl`, the content doesn't have to be an image. Hand it any XAML tree and the whole thing scales: shapes and text stay crisp at every zoom level, and controls buried in the content stay fully interactive.

{% include local-video.html src="/assets/images/zoomcontentcontrol/xaml-demo.mp4" caption="A plain XAML tree of borders, shapes, and live controls getting the same zoom-and-pan treatment. Vector content stays crisp all the way in." %}

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

A quick note on expectations, because I don't want you to be surprised: in the packages shipping today, the built-in interactions above are mouse- and keyboard-driven — no pinch-to-zoom or drag-to-pan baked in. Writing this post made that gap annoying enough to do something about it: [uno.toolkit.ui#1630](https://github.com/unoplatform/uno.toolkit.ui/pull/1630) wires standard touch and pen gestures into the control — pinch to zoom around your fingers' focal point, single-finger drag to pan (with inertia), reusing the same anchor math as the Ctrl + wheel zoom. Until that reaches a package near you, drive `ZoomLevel` yourself with some buttons on touch. Which, conveniently, is exactly what we're about to do.
{: .notice--warning}

{% include local-video.html src="/assets/images/zoomcontentcontrol/touch-gestures.mp4" class="width-half align-center" caption="The new touch gestures from uno.toolkit.ui#1630 on Android: pinching into the image, then pinching and dragging around the XAML tree — and typing into the zoomed TextBox on the way, because the content stays live." %}

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

{% include local-video.html src="/assets/images/zoomcontentcontrol/buttons.mp4" caption="Stepping the zoom from code, then ResetViewport() back to 100%." %}

And that's the whole trick. If you're doing this in an MVVM or MVUX app, `ZoomLevel` binds just as happily to a view model property.

## The Helper Methods

That `ResetButton` above calls `ResetViewport()`, which is one of a handful of convenience methods the control exposes. Here's the full set and what each one actually does:

| Method            | What it does                                                 |
| ----------------- | ------------------------------------------------------------ |
| `ResetZoom()`     | Sets `ZoomLevel` back to `1`                                 |
| `ResetScroll()`   | Resets the scroll/pan position to `(0, 0)`                   |
| `ResetViewport()` | `ResetZoom()` + `CenterContent()`: back to 100%, re-centered |
| `CenterContent()` | Centers the content within the viewport                      |
| `FitToCanvas()`   | Adjusts `ZoomLevel` so the content fits the available space  |

`FitToCanvas()` is the juicy one. If you've got a document or a diagram and you want the classic "fit to page" behavior, that's your button. And if you'd rather it happen automatically whenever the content or viewport size changes? You don't even need the button, as we'll see next.

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

{% include local-video.html src="/assets/images/zoomcontentcontrol/focus-demo.mp4" caption="ElementOnFocus pointed at each node of the diagram in turn: the control snaps its fit-and-center behavior to whichever element has focus, then back to the whole tree." %}

## So Why Not Just a ScrollViewer?

Since `ScrollViewer` zoom support landed in Uno ([uno#22337](https://github.com/unoplatform/uno/pull/22337)), this question deserves an honest answer. So I[^not-me] rebuilt both demos from this post, the image viewer and the zoomable XAML tree, on a plain `ScrollViewer` ([kazo0/ScrollViewerZoomSample][svz-sample], if you want to run the comparison yourself). The XAML side is nice and clean:

```xml
<ScrollViewer x:Name="Scroller"
              ZoomMode="Enabled"
              MinZoomFactor="0.1"
              MaxZoomFactor="8"
              HorizontalScrollBarVisibility="Auto"
              VerticalScrollBarVisibility="Auto">
    <Image Source="ms-appx:///Assets/profile.png"
           Stretch="None"
           HorizontalAlignment="Center"
           VerticalAlignment="Center" />
</ScrollViewer>
```

{% include local-video.html src="/assets/images/zoomcontentcontrol/scrollviewer-demo.mp4" caption="The same image demo on a plain ScrollViewer: fit on open, zoom from code, pan, fit again" %}

The catch is everything this post has been about: driving the view *from code*. `ZoomFactor` and the offsets are **read-only** on `ScrollViewer`, so every programmatic view change funnels through one method, `ChangeView(horizontalOffset, verticalOffset, zoomFactor)`, and every convenience you saw earlier becomes your own helper method. A few I had to write to reach feature parity with the demos above:

```csharp
// FitToCanvas(), by hand
var zoom = Math.Min(sv.ViewportWidth / content.ActualWidth,
                    sv.ViewportHeight / content.ActualHeight);
sv.ChangeView(0, 0, (float)Math.Clamp(zoom, sv.MinZoomFactor, sv.MaxZoomFactor));

// CenterContent(), by hand
sv.ChangeView(sv.ScrollableWidth / 2, sv.ScrollableHeight / 2, null);

// ElementOnFocus, by hand: fit-and-center one element
var rect = element.TransformToVisual(content)
    .TransformBounds(new Rect(0, 0, element.ActualWidth, element.ActualHeight));
var z = Math.Clamp(Math.Min(sv.ViewportWidth / rect.Width, sv.ViewportHeight / rect.Height),
                   sv.MinZoomFactor, sv.MaxZoomFactor);
sv.ChangeView((rect.X + rect.Width / 2) * z - sv.ViewportWidth / 2,
              (rect.Y + rect.Height / 2) * z - sv.ViewportHeight / 2, (float)z);
```

{% include local-video.html src="/assets/images/zoomcontentcontrol/scrollviewer-focus.mp4" caption="The 'element on focus' demo rebuilt on ScrollViewer" %}

It all works, as the videos show. But a scorecard of what I re-implemented (or couldn't) fills in the rest:

| `ZoomContentControl` | Plain `ScrollViewer` |
| --- | --- |
| `ZoomLevel = x`, settable and two-way bindable | `ChangeView(null, null, x)`, plus syncing your slider back from `ViewChanged` yourself |
| `FitToCanvas()` / `CenterContent()` / `ResetViewport()` | the helpers above |
| `AutoFitToCanvas`, `AutoCenterContent` | refit from `SizeChanged` in code-behind; center via content alignment |
| `ElementOnFocus` / `SetLocalFocus(...)` | `TransformToVisual` + rect math |
| Zooming from code keeps the content anchored sensibly | a bare zoom `ChangeView` anchors the **top-left**, so "zoom about the center" is more offset math |
| `AdditionalMargin`, `AllowFreePanning`, wheel-ratio knobs, middle-click pan | no equivalent |
| Touch pinch zoom | **built in** — point, `ScrollViewer` (though [#1630](https://github.com/unoplatform/uno.toolkit.ui/pull/1630) evens this one out) |

## Conclusion

Both sample apps from this post are on GitHub if you want to clone them and follow along: [ZoomContentControlSample][zcc-sample] for the control itself, [ScrollViewerZoomSample][svz-sample] for the `ScrollViewer` rebuild.

Fittingly, putting this post together shook a couple of real bugs out of the control itself: zooming from code across the point where the content fits the viewport (or zooming with an `AdditionalMargin` set) could land the content off-center. Both are fixed in [uno.toolkit.ui#1628](https://github.com/unoplatform/uno.toolkit.ui/pull/1628), so if your content drifts on zoom with an older package version, that's why. And the touch gap called out earlier turned into a feature: [uno.toolkit.ui#1629](https://github.com/unoplatform/uno.toolkit.ui/issues/1629) / [#1630](https://github.com/unoplatform/uno.toolkit.ui/pull/1630) add pinch-to-zoom and drag-to-pan, as seen in the Android video above. Toolkit Tuesdays: come for the control tour, stay for the bug fixes.

I hope you enjoyed this edition of Toolkit Tuesdays! As always, I encourage you to consult the full documentation using the links below, and to jump into the fun on the [Uno Toolkit GitHub repo][uno-toolkit] if you find a bug, want to make an improvement, or want to help the docs along.

## Further Reading

- [ZoomContentControl Docs][zoomcontentcontrol-docs]
- [Uno Toolkit Docs][uno-toolkit-docs]
- [ZoomContentControlSample][zcc-sample] — the runnable sample behind this post's demos
- [ScrollViewerZoomSample][svz-sample] — the same demos rebuilt on a plain `ScrollViewer`

## Footnotes

[^ish]: -ish
[^bop-it-yt]: [I feel so old](https://www.youtube.com/watch?v=oY82qDgYFjA)
[^not-me]: Claude

[zoomcontentcontrol-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/ZoomContentControl.html
[zcc-sample]: https://github.com/kazo0/ZoomContentControlSample
[svz-sample]: https://github.com/kazo0/ScrollViewerZoomSample
{% include links.md %}
