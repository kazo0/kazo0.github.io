---
title: "Toolkit Tuesdays: LoadingView"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, loadingview, loading, iloadable, progressring, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][toolkit-homepage] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-homepage]. I hope you find them useful too!

This week we're covering the `LoadingView`, and there's a decent chance you've already used it without realizing. If you read the [ExtendedSplashScreen post]({% post_url 2024-03-12-toolkit-tuesday-extendedsplashscreen %}), you met `LoadingView` in passing: the `ExtendedSplashScreen` is actually derived from it. Today it gets to be the star of the show.

As always, these components need a little extra setup since they're part of the Uno Toolkit library. You can refer to the [Getting Started documentation][uno-toolkit-docs] to get everything wired up.
{: .notice--info}

{% include video id="3cpjJ3keBvM" provider="youtube" %}

Everything below comes from a companion sample you can clone and run: [kazo0/LoadingViewSample][sample-repo]. It's a plain `dotnet new unoapp -preset blank -toolkit` project with the three demos from this post wired up, and each snippet links straight to the lines it came from.
{: .notice--info}

## The Problem (and The Solution)

Here's a pattern you've almost certainly written before. You've got some content, a list of forecasts, a details panel, whatever, and it depends on an async call. So you add an `IsBusy` flag to your view model, flip it to `true` before the call and `false` after, and then bind a `ProgressRing`'s visibility to `IsBusy` and your content's visibility to the inverse. Maybe you write a `BoolToVisibilityConverter` or two. It works, but you write it again on the next page, and the one after that.

`LoadingView` is the Toolkit's answer to that repetition. It's a `ContentControl` that shows your content once it's ready and swaps in a loading indicator while it isn't, and it figures out which state it's in by watching a single source. No visibility converters, no manually toggling anything.

## Anatomy of a `LoadingView`

Under the hood, the control's template is a `Grid` with two presenters stacked directly on top of each other. Which one you actually see comes down to a single visual state:

1. **Content**: The real thing you want to show. This is the default child of the control, so anything you nest directly inside a `<utu:LoadingView>` ends up here. It starts out fully transparent and non-interactive, and only fades in once loading has finished.
2. **Loading Content**: What sits on top of the _Content_ layer while you wait, set through the `LoadingContent` property. A `ProgressRing`, a skeleton view, some branding, whatever you like. It's shown from the moment the template is applied, and fades back out as the _Content_ layer fades in.

If that layering sounds familiar, it should. It's the same sandwich the [`ExtendedSplashScreen`]({% post_url 2024-03-12-toolkit-tuesday-extendedsplashscreen %}) builds on, which makes sense given it derives from `LoadingView` and simply slips the native splash screen image in as a middle layer.

### `Source`

The one everything hinges on. `Source` is the `ILoadable` the control watches to decide which layer wins, and it's the subject of the next section. The control subscribes to that object's `IsExecutingChanged` and re-evaluates its state every time it fires, so you set this once and never touch it again.

### `LoadingContent`

The layer shown while you're waiting. It's typed as `object`, so a `ProgressRing` is the common case but anything goes. If you'd rather drive it from a template than hand it a literal element, there are `LoadingContentTemplate` and `LoadingContentTemplateSelector` properties to match, exactly as you'd expect from any `ContentControl`-shaped API.

The template also toggles the [`ProgressExtensions.IsActive`][progress-docs] attached property on whatever you put here as it moves between states, which is a nicety we'll come back to in [Basic Usage](#basic-usage).

### Visual States

All of the above is driven by a `LoadingStates` visual state group holding exactly two states, `Loading` and `Loaded`. Worth knowing if you ever go to re-template the control or hang your own state setters off it, since those names are the whole vocabulary.

## Getting to Know `ILoadable`

The "single source" `LoadingView` watches is anything that implements `ILoadable`. It's about as small an interface as you'll ever see:

```csharp
public interface ILoadable
{
    bool IsExecuting { get; }
    event EventHandler? IsExecutingChanged;
}
```

That's the whole contract. `IsExecuting` tells the `LoadingView` whether work is happening, and `IsExecutingChanged` lets it know when to re-check. When `IsExecuting` is `true`, `LoadingView` shows your loading content. When it flips to `false`, it fades your real content in.

One small thing that'll trip you up the first time you go to implement it: `ILoadable` lives in the `Uno.Toolkit` namespace, not `Uno.Toolkit.UI` where the controls live. You'll want a `using Uno.Toolkit;` alongside your usual Toolkit usings.
{: .notice--warning}

We built a custom `ILoadable` from scratch in the [ExtendedSplashScreen post]({% post_url 2024-03-12-toolkit-tuesday-extendedsplashscreen %}) if you want to see one in full, so I won't repeat that here. Instead, let's look at the ways you'll actually get an `ILoadable` in practice.

## Basic Usage

Let's start with the simplest possible setup. A `LoadingView` has two conceptual pieces: its `Content` (the real thing you want to show) and its `LoadingContent` (what shows while you wait). You point its `Source` at an `ILoadable`, and the control does the rest.

```xml
<utu:LoadingView Source="{Binding FetchWeatherForecasts}">
    <Grid RowDefinitions="Auto,*">
        <Button Grid.Row="0"
                Content="Refresh"
                Command="{Binding FetchWeatherForecasts}" />
        <ListView Grid.Row="1"
                  ItemsSource="{Binding Forecasts}" />
    </Grid>

    <utu:LoadingView.LoadingContent>
        <ProgressRing IsActive="True" />
    </utu:LoadingView.LoadingContent>
</utu:LoadingView>
```

The default child of the `LoadingView` (the `Grid` here) is its `Content`. The `LoadingContent` is the `ProgressRing`. While `FetchWeatherForecasts` reports that it's executing, you see the ring; once it's done, the `ListView` fades in as the ring fades away.

You can see this one running in the sample: [`MainPage.xaml`][sample-basic], backed by [`MainViewModel.cs`][sample-viewmodel].

One small nicety: `LoadingView`'s template automatically toggles the [`ProgressExtensions.IsActive`][progress-docs] attached property on your loading content as it moves between states. So even if you forget to bind `IsActive`, a `ProgressRing` sitting in your `LoadingContent` will start and stop spinning along with the loading state. It's a little detail, but it's a nice feature to ensure you don't have an invisible but still-spinning ring sitting there burning CPU cycles while your content is already visible.

## Busy-Aware Commands

You might have noticed something in that last snippet: the same `FetchWeatherForecasts` is bound to both the button's `Command` and the `LoadingView`'s `Source`. That's not a typo. It's the nicest way to use this control.

The trick is a command that also implements `ILoadable`. Here's a compact `AsyncCommand` that does exactly that, lightly adapted from the [Toolkit docs][loadingview-docs]:

```csharp
public class AsyncCommand : ICommand, ILoadable
{
    public event EventHandler? CanExecuteChanged;
    public event EventHandler? IsExecutingChanged;

    private readonly Func<Task> _executeAsync;
    private bool _isExecuting;

    public AsyncCommand(Func<Task> executeAsync) => _executeAsync = executeAsync;

    public bool CanExecute(object? parameter) => !IsExecuting;

    public bool IsExecuting
    {
        get => _isExecuting;
        set
        {
            if (_isExecuting != value)
            {
                _isExecuting = value;
                IsExecutingChanged?.Invoke(this, new());
                CanExecuteChanged?.Invoke(this, new());
            }
        }
    }

    public async void Execute(object? parameter)
    {
        try
        {
            IsExecuting = true;
            await _executeAsync();
        }
        finally
        {
            IsExecuting = false;
        }
    }
}
```

That class is in the sample as [`AsyncCommand.cs`][sample-asynccommand] if you'd rather copy it from something that compiles.

Because this command is both an `ICommand` and an `ILoadable`, one object can drive a button AND a `LoadingView`. Tap the button, the command sets `IsExecuting = true`, the `LoadingView` sees it through the `Source` binding and shows your spinner, and when the awaited work finishes the `finally` block flips it back and your content returns. The button even disables itself while it runs, since `CanExecute` returns `!IsExecuting`. All of that from a single binding on each side.

### You Already Have This in MVUX

Here's the nice part: if you're building with MVUX, you don't have to write that class at all. Any public method on an MVUX model that returns `void`, `Task`, or `ValueTask` gets generated into an `IAsyncCommand`, and that interface is declared like this:

```csharp
public interface IAsyncCommand : ICommand, INotifyPropertyChanged, ILoadable
{
}
```

`ILoadable` is right there in the list. So a generated MVUX command is already a valid `LoadingView.Source`, and the whole "one object drives both sides" trick works with nothing extra to write. No `AsyncCommand`, no `IsBusy`, no `INotifyPropertyChanged`.

That said, the sample app for this post sticks with the hand-rolled `AsyncCommand`, and that's on purpose: as we'll get to [below](#loadingview-or-feedview), an MVUX app would usually reach for `FeedView` here instead. `LoadingView`'s home turf is exactly the app that _isn't_ using MVUX.

## Waiting on Multiple Sources

Real pages rarely load exactly one thing. Say you've got two independent calls feeding two lists, and you want to keep showing the loading state until BOTH have come back. The Toolkit has a pair of helpers for exactly this: `LoadableSource` and `CompositeLoadableSource`.

```xml
<utu:LoadingView>
    <utu:LoadingView.Source>
        <utu:CompositeLoadableSource>
            <utu:LoadableSource Source="{Binding LoadContent0Command}" />
            <utu:LoadableSource Source="{Binding LoadContent1Command}" />
        </utu:CompositeLoadableSource>
    </utu:LoadingView.Source>

    <StackPanel>
        <ListView ItemsSource="{Binding Content0}" />
        <ListView ItemsSource="{Binding Content1}" />
    </StackPanel>

    <utu:LoadingView.LoadingContent>
        <ProgressRing IsActive="True" />
    </utu:LoadingView.LoadingContent>
</utu:LoadingView>
```

A `CompositeLoadableSource` aggregates any number of nested sources and reports itself as executing when ANY one of them is. So the spinner stays up until the slowest call finishes, then everything appears together. No juggling multiple flags, no `&&`-ing booleans in a converter.

The sample wires this up with an 800ms call and a 3000ms one so the difference is obvious: [`MainPage.xaml`][sample-composite]. Worth noting that its `ProgressRing` there deliberately has no `IsActive="True"` on it, and still spins, thanks to the `ProgressExtensions.IsActive` toggling mentioned above.

## LoadingView or FeedView?

If you've followed along with the [Uno Chefs walkthrough]({% post_url 2025-07-02-chefs-login %}) series, you might be thinking this sounds an awful lot like the `FeedView` control that's all over that app's XAML. They do overlap, so let's be clear about when to reach for which.

`FeedView` comes from Uno Extensions Reactive and is built specifically for MVUX. It understands feeds and states, and it gives you distinct visual states for loading, error, AND empty (`NoneTemplate`) data on top of your data template. If you're already all-in on MVUX, it's the natural fit, and it does more than `LoadingView` does.

`LoadingView` is the more general tool. It doesn't know or care about MVUX. All it needs is an `ILoadable`, which means it works just as happily in a classic MVVM app, or wrapped around a single command, or driving an extended splash screen. It's a focused "is this busy or not" wrapper you can drop anywhere.

The way I think about it: if you're consuming an MVUX feed, use `FeedView`. If you just need to show a busy indicator over some content while an arbitrary bit of work runs, and especially if you're not using MVUX at all, `LoadingView` is your control.

## Conclusion

`LoadingView` is one of those small controls that quietly deletes a bunch of boilerplate you'd otherwise write on every other page. Point its `Source` at an `ILoadable`, hand it some `LoadingContent`, and it takes care of the rest, whether that source is a single busy-aware command or a whole `CompositeLoadableSource` of them. And now you know it's the same engine powering the `ExtendedSplashScreen`, so the two posts tie together nicely.

As always, I'd encourage you to read through the full docs below, and if you spot a bug or think of an improvement, `LoadingView` and the rest of the Toolkit are open source and very open to contributions. Jump into the fun on the [Uno Toolkit GitHub repo][uno-toolkit]!

I hope you enjoyed this edition of Toolkit Tuesdays, and I'll catch you in the next one :wave:

## Further Reading

- [Sample app for this post][sample-repo]
- [LoadingView Docs][loadingview-docs]
- [ExtendedSplashScreen Docs][extsplashscreen-docs]
- [Uno Toolkit Docs][uno-toolkit-docs]

[loadingview-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/LoadingView.html
[extsplashscreen-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/ExtendedSplashScreen.html
[progress-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/progress-extensions.html
[sample-repo]: https://github.com/kazo0/LoadingViewSample
[sample-basic]: https://github.com/kazo0/LoadingViewSample/blob/bece4cdd6732b6b7a5abadff6e2622a06b736412/LoadingViewSample/MainPage.xaml#L61-L77
[sample-viewmodel]: https://github.com/kazo0/LoadingViewSample/blob/bece4cdd6732b6b7a5abadff6e2622a06b736412/LoadingViewSample/MainViewModel.cs
[sample-asynccommand]: https://github.com/kazo0/LoadingViewSample/blob/bece4cdd6732b6b7a5abadff6e2622a06b736412/LoadingViewSample/AsyncCommand.cs#L14-L55
[sample-composite]: https://github.com/kazo0/LoadingViewSample/blob/bece4cdd6732b6b7a5abadff6e2622a06b736412/LoadingViewSample/MainPage.xaml#L93-L116
{% include links.md %}
