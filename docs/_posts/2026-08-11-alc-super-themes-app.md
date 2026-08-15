---
title: "Uno Apps Inside of Uno Apps"
category: uno-general
header:
  teaser: /assets/images/alc-super-themes/hero.png
  og_image: /assets/images/alc-super-themes/hero.png
tags: [uno-platform, uno, assemblyloadcontext, alc, hot-design, themes, skia, wasm]
---

I posted a fun little experiment the other day and I wanted to follow it up with the real story of how it works. Here's [the tweet][tweet]:

> Running your @UnoPlatform apps inside of your @UnoPlatform apps ;)
>
> Inspired by the plumbing of Uno Platform Studio, I thought it'd be fun to take advantage of AssemblyLoadContext to load each Uno Themes sample app inside of a new SUPER THEMES APP. Works surprisingly well!

And here's the thing actually running. One app, and I'm picking which whole other app renders inside it, live:

{% include local-video.html
     src="/assets/images/alc-super-themes/super-themes-demo.mp4"
     poster="/assets/images/alc-super-themes/super-themes-demo-poster.png" %}

## What Even Is This

The [Uno.Themes repo][uno-themes] contains three sample apps, one per design system: Material, Simple, and Cupertino (out of support). I wanted a single app where I could tap a button and load any of them, then unload it and load the next one. The catch is that these aren't little user controls I'm swapping in. Each one is a complete, independent Uno application, with its own resources, its own theme library, its own everything. What you're watching in that video is one Uno app hosting another entire Uno app, swapping between three of them, with a <i>clean</i><sup>*</sup> teardown in between.

## But Like, Why?

 > Is this just some flashy demoware?

 No! I have reasons; and they are threefold:

 1. This is the underlying plumbing the powers [Uno Platform Studio][uno-studio], more on that [later](#standing-on-uno-studios-shoulders)

 2. Today, testing each Themes app means launching a different sample head for each one. It means packaging each one separately. It means deploying to three separate slots in the dev environment via the CI. It means a larger, more complex setup locally and on the CI. It's also a way to test the themes in a single staging slot for every pull request, instead of three separate ones.

 3. It's also a single entry point for automated runtime tests that need to run against all three themes. Imagine having a single "runner" app that is capable of being provided a set of automated runtime test cases, and then running them against the live app to be tested. That's the payoff.

<a href="/assets/images/alc-super-themes/themes-running.png" class="image-popup"><img class="align-center" src="/assets/images/alc-super-themes/themes-running.png" alt="The wrapper app hosting the Material, Cupertino, and Simple theme samples one at a time, each showing an 'is running' status"/></a>

## A Quick Word on AssemblyLoadContext

The piece of .NET that makes this possible is [`AssemblyLoadContext`][alc-docs], or ALC. If you've never had a reason to reach for it, here's the two-minute version.

Normally every assembly your app loads goes into one big shared bucket, the default load context. ALC lets you create additional, isolated buckets. Two different contexts can each load an assembly with the same name, even different versions of it, and the runtime treats them as genuinely separate. Worth being precise about "isolated" though, because it isn't a sandbox. There's no binary isolation between contexts, they're only isolated by not finding each other by name.

And things get weird when you start sharing types across contexts.

## Standing on Uno Studio's Shoulders

I did not invent the hard part here. [Uno Platform Studio][uno-studio] already does exactly this in production: it loads your app into a fresh collectible `AssemblyLoadContext` and runs it inside the Studio process itself. [Hot Design][hot-design] then rides along inside that same context, which is how it can turn your live, running app into a designer. That plumbing is exactly what I needed: loading and running a whole app inside another app's world. The Uno runtime exposes the pieces that make it work as public API, and I just wired them together for a much simpler purpose.

There are really only three moving parts:

- [`AlcContentHost`][alc-uno-code], a `ContentControl` you drop into your visual tree to reserve a spot for the guest.
- [`WindowHelper.ContentHostOverride`][contenthostoverride-uno-code], which allows the guest's window content to be redirected to that `AlcContentHost`.
- A second `UnoPlatformHostBuilder`, which you build around the guest's `Application` and run.

## The Host Side

On the parent app's main page, I create the `AlcContentHost` once and register it as the override for the whole app's lifetime:

```csharp
_contentHost = new AlcContentHost { HorizontalAlignment = HorizontalAlignment.Stretch };
GuestRegion.Child = _contentHost;

// Redirect any hosted guest's window into our region.
WindowHelper.ContentHostOverride = _contentHost;
```

Source: [`ThemesSampleApp/MainPage.xaml.cs`][src-mainpage]
{: .code-caption}

When you pick a theme, the loader creates a fresh collectible ALC, loads the guest's assemblies into it, and starts the guest with its own host builder. The important subtlety is what gets shared versus isolated. The Uno framework assemblies (`Uno.UI` and friends) are shared from the default context, because if the host and the guest each loaded their own `Uno.UI`, their types would not be the same types and nothing would line up. The guest's own code and its theme library, on the other hand, stay fully isolated inside the collectible context. That whole shared-versus-isolated policy now lives in a single data file that both the loader and the build step read, so the runtime and the packaging can never quietly drift apart.

Starting the guest looks roughly like this. Note that it never runs the guest's `Program.Main`, it builds a brand new host around the guest's `App`:

```csharp
var builder = UnoPlatformHostBuilder.Create().App(capturingFactory);
#if __WASM__
    builder = builder.UseWebAssembly();
#else
    builder = builder.UseX11().UseLinuxFrameBuffer().UseMacOS().UseWin32();
#endif
var host = builder.Build();
```

Source: [`GuestAppLoader.Desktop.cs`][src-host-desktop] and [`GuestAppLoader.Wasm.cs`][src-host-wasm] — split per platform in the repo rather than `#if`'d in one file
{: .code-caption}

From there the guest constructs its `App`, sets up its window, and Uno quietly redirects that window's content into the `AlcContentHost`. The guest thinks it's a normal top-level app. It has no idea it's a guest. There's an important subtlety here about how the guest app's content is plumbed through. We aren't dealing nesting Windows or multiple App instances or multiple independent visual trees. When we set the `WindowHelper.ContentHostOverride` to `_contentHost`, we are telling the Uno runtime that any `Window` created in the guest context should have its content redirected to the `AlcContentHost`. This allows the guest app to behave as if it has its own window, while actually rendering inside the host's visual tree. So, one visual tree for both apps.

And yes, it makes resource resolution a bitch sometimes.

## Two Tiny Changes to Each Guest

The coolest part is how little the sample apps had to change to become hostable. Exactly two things, and both are one-liners.

First, one property in the csproj so the XAML generator knows this app might be hosted and scopes its resource dictionaries to the right load context. Basically, this is how we can ensure that the guest's static resources don't leak into the host's world, and vice versa. Well, actually, it's how the XAML generator knows to generate code that allows us to know which resources belong to which context. The Uno XAML generator has to be aware of the hosting scenario so it can generate code that respects the boundaries of the load contexts.

Add this to the guest's csproj:

```xml
<UnoEnableAlcAppSupport>true</UnoEnableAlcAppSupport>
```

Source: [`MaterialSampleApp.csproj`][src-alc-support] — identical line in the Cupertino and Simple heads
{: .code-caption}

Second, and this one is a genuine gotcha, the sample apps used to grab their window like this:

```csharp
MainWindow = Microsoft.UI.Xaml.Window.Current;
```

`Window.Current` is a process-wide static living in the shared `Uno.UI`. When the app runs hosted, that static is the wrapper's window, so the guest would reach up and grab the host's window and promptly try to close it. The fix is to just make a new one:

```csharp
MainWindow = new Microsoft.UI.Xaml.Window();
```

Source: [`MaterialSampleApp/App.xaml.cs`][src-new-window] — identical line in the Cupertino and Simple heads
{: .code-caption}

That's still correct when the app runs standalone, because the first `new Window()` maps to the main window anyway. So the sample heads stay completely standalone. They gained the ability to be hosted without giving up the ability to run on their own.

## Guests Overstaying Their Welcome

Just the thought of loading, unloading, switching, and reloading assemblies over and over again during the app's lifetime is causing my RAM usage to skyrocket. It sounds like a recipe for leaks, and it is. The collectible ALC is supposed to reclaim its memory when nothing outside it points at anything inside it But, Uno's shared assemblies are non-collectible code that can hold references into the guest. If a static in `Uno.UI` still points at a guest object after teardown, the whole context stays alive.

The direction matters here: Guest → host references are fine. Host → guest is what kills you. A non-collectible root reaching into collectible memory. And it's not always as straightforward as it sounds. In fact, as a result of this app and blog, we identified a few leaks that need to be cleaned up! More on that [in a bit](#sweeping-up).

This is why we now have a hosting smoke test wired into CI: every build loads all three guests, unloads them, and asserts that each load context was actually reclaimed. If a future change starts leaking, the build fails instead of the leak sneaking through.

The test itself is boring in the best way. Launch the wrapper with `--smoke` on desktop or `?smoke` in the browser and [it drives itself][smoke]: load each guest in turn, unload the last one, and check reclamation after every step. It's not perfect, I know. Technically, we should be be loading and unloading over and over again and tracking a count of retained references that should be kept underneath a realistic threshold, but this is a smoke test, not a stress test.

### The Eviction

The eviction is the part that actually tears down the guest. It calls `ExitAlcApplication()` to clean up the guest's static caches, then it sweeps a few Uno internals to make sure nothing is still pointing at the collectible context. Finally, it drops its reference to the ALC and forces a GC collection, then probes to see if the context was reclaimed.

It starts politely, by asking the guest to exit itself. `Application.Exit()` is what internally triggers `ExitAlcApplication()`, which sweeps the per-ALC static caches:

```csharp
if (session.GuestApp is { } guestApp)
{
    await RunOnUIThreadAsync(guestApp.Exit).ConfigureAwait(false);
}
```

Source: [`GuestAppLoader.TeardownUnguardedAsync`][evict-exit]
{: .code-caption}

Then every reference the session holds gets dropped before the unload, because anything still pointing into the guest at this moment pins the context. The weak reference is deliberately the *only* thing left holding the ALC:

```csharp
var alc = session.Alc;
session.GuestApp = null;
session.ExecutionTask = null;
session.ExecutionThread = null;

await Task.Run(alc.Dispose).ConfigureAwait(false);
_lastUnloadedAlc = new WeakReference<GuestAssemblyLoadContext>(alc);
```

Source: [`GuestAppLoader.TeardownUnguardedAsync`][teardown]
{: .code-caption}

Ordering is the whole trick in the next bit. Guest `DependencyObject` finalizers run *during* the unload and can re-populate the shared property-system caches after `ExitAlcApplication` already swept them, so the sweep has to come after the finalizers drain, not before:

```csharp
GC.Collect();
await DrainFinalizersAsync().ConfigureAwait(false);
await RunOnUIThreadAsync(SweepNonDefaultAlcCaches).ConfigureAwait(false);

GC.Collect();
```

Source: [`GuestAppLoader.TeardownUnguardedAsync`][evict-sweep] — the sweep call is wrapped in a warning check in the repo
{: .code-caption}

And the verdict is just a weak-reference probe. If the target is still reachable after all that, something in the host is still rooting the guest:

```csharp
if (weakAlc.TryGetTarget(out var previous))
{
    LastUnloadedAlcCollected = false;
    _logger.LogWarning("Previous guest ALC {Name} is still alive after unload + GC.", previous.Name);
}
else
{
    LastUnloadedAlcCollected = true;
}
```

Source: [`GuestAppLoader.ReportPreviousAlcCollectionState`][smoke-probe]
{: .code-caption}

### Sweeping Up

That `SweepNonDefaultAlcCaches` call is the honest ugly part. It's three reflection-based pokes at Uno internals, deliberately parked in [one file][sweeps] so they're easy to delete later, and every one of them degrades to a logged warning rather than an exception if a future Uno rename moves the target.

I won't go into each sweep, but we can focus on what I think is the most interesting one. This is the one that that illustrates the hidden complexity of the `Guest → host references are fine. Host → guest is what kills you` rule. The `SystemNavigationManager.BackRequested` event is a process-wide static in the shared `Uno.UI`, and the guest's `Shell` subscribes to it. At face-value, this may sound like a guest -> host reference. But this is one of those pesky cases where the guest's subscription roots the guest itself. The event is a multicast delegate, and the invocation list holds strong references to each subscriber.

 Nothing unsubscribes it on teardown, so the stale handler roots the guest's entire visual tree. The fix is to walk the invocation list and drop anything whose origin lives in a collectible context:

- **[Pruning `SystemNavigationManager` handlers][sweep-nav].** The samples' `Shell` subscribes to the process-wide `BackRequested` and nothing unsubscribes it on teardown, so the stale handler roots the guest's entire visual tree ([uno#24074][issue-nav]).

#### Remaining Sweeps

- **[Re-running Uno's own cache sweep][sweep-finalizers].** ([uno#24075][issue-finalizers])
- **[Clearing `DependencyProperty._getPropertyCache`][sweep-dp].** ([uno#24073][issue-dp])

## Why Bother

Beyond it just being cool, there's a real payoff. The Uno.Themes repo deploys a staging site for every pull request, and it used to only cover the Simple theme. This wrapper now lets one deployment host all three theme samples behind a picker, so every PR gets a single staging site that covers Material, Cupertino, and Simple at once. The fun demo turned into an actual improvement to how we test the themes.

There's also something I like about pulling back the curtain. The ALC hosting that powers Uno Platform Studio can feel like magic when it's buried inside a product. Wiring it up myself, and hitting all the sharp edges, made it a lot less magical and a lot more approachable. If you want to see the whole thing, warts and workarounds included, all of the code is in the [pull request][pr].

I should also mention I built this with Claude, which fits right in with the [agentic development]({% post_url 2026-02-23-agent-skills-intro %}) thread I've been on lately. Chasing down a trimmer stripping type-forwarders is exactly the kind of deep, weird problem where having a tireless pair helps.

## Conclusion

So there it is. Uno apps running inside Uno apps, one collectible load context at a time, built on the same runtime plumbing that Uno Platform Studio uses in production. It started as a "wouldn't it be funny if" and turned into both a genuine testing improvement and the most I've learned about `AssemblyLoadContext` in one sitting.

If you go try something like this yourself, do it on a 6.7 build (may still be prerelease -dev builds at the time of this post) and expect to get friendly with load contexts. And if you build something sillier than a SUPER THEMES APP, please come show me in the [Uno Discord][uno-discord] ;).

Catch you in the next one :wave:

<i><sup>*</sup> We are still hunting down some leaks, we've made good progress but memory management is hard ok? Give us a break.</i>

[tweet]: https://x.com/BiloganSteve/status/2087173345322152018
[uno-discord]: https://platform.uno/discord
[pr]: https://github.com/unoplatform/Uno.Themes/pull/1693
[alc-docs]: https://learn.microsoft.com/en-us/dotnet/core/dependency-loading/understanding-assemblyloadcontext
[uno-studio]: https://platform.uno/studio/
[hot-design]: https://platform.uno/docs/articles/studio/Hot%20Design/hot-design-overview.html
[uno-themes]: https://github.com/unoplatform/Uno.Themes
[src-mainpage]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/MainPage.xaml.cs#L28-L39
[src-host-desktop]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Desktop.cs#L18-L25
[src-host-wasm]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Wasm.cs#L14-L18
[src-alc-support]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/MaterialSampleApp/MaterialSampleApp.csproj#L22
[src-new-window]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/MaterialSampleApp/App.xaml.cs#L38
[teardown]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.cs#L459-L480
[sweeps]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs
[sweep-finalizers]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs#L25-L28
[sweep-dp]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs#L30-L41
[sweep-nav]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs#L114-L166
[smoke]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestHostingSmoke.cs
[smoke-probe]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.cs#L490-L509
[evict-exit]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.cs#L403-L421
[evict-sweep]: https://github.com/unoplatform/Uno.Themes/blob/d20cd74337c6e5b8564a9871be46243a0bac8aac/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.cs#L468-L480
[issue-dp]: https://github.com/unoplatform/uno/issues/24073
[issue-nav]: https://github.com/unoplatform/uno/issues/24074
[issue-finalizers]: https://github.com/unoplatform/uno/issues/24075
[alc-uno-code]: https://github.com/unoplatform/uno/blob/bfecdcb7e5dbcbf49903439b5cb3681c28cbd15a/src/Uno.UI/UI/Xaml/Window/AlcContentHost.cs#L15
[contenthostoverride-uno-code]: https://github.com/unoplatform/uno/blob/bfecdcb7e5dbcbf49903439b5cb3681c28cbd15a/src/Uno.UI/UI/Xaml/Window/WindowHelper.cs#L39
{% include links.md %}
