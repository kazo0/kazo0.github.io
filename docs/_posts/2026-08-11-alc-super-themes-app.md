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

The [Uno.Themes repo][uno-themes] contains three sample apps, one per design system: Material, Simple, and Cupertino (out of support). I wanted a single app where I could tap a button and load any of them, then unload it and load the next one. The catch is that these aren't little user controls I'm swapping in. Each one is a complete, independent Uno application, with its own `App` class, its own resources, its own theme library, its own everything. What you're watching in that video is one Uno app hosting another entire Uno app, swapping between three of them, with a <i>clean</i><sup>*</sup> teardown in between.

## But Like, Why?

 > Is this just some flashy demoware?

 No! I have reasons; and they are threefold:

 1. This is the underlying plumbing the powers [Uno Platform Studio][uno-studio], more on that [later](#standing-on-uno-studios-shoulders)

 2. Today, testing each Themes app means launching a different sample head for each one. It means packaging each one separately. It means deploying to three separate slots in the dev environment via the CI. It means a larger, more complex setup locally and on the CI. It's also a way to test the themes in a single staging slot for every pull request, instead of three separate ones.

 3. It's also a single entry point for automated runtime tests that need to run against all three themes. Imagine having a single "runner" app that is capable of being provided a set of automated runtime test cases, and then running them against the live app to be tested. That's the payoff.

<a href="/assets/images/alc-super-themes/themes-running.png"><img class="align-center" src="/assets/images/alc-super-themes/themes-running.png" alt="The wrapper app hosting the Material, Cupertino, and Simple theme samples one at a time, each showing an 'is running' status"/></a>

## A Quick Word on AssemblyLoadContext

The piece of .NET that makes this possible is [`AssemblyLoadContext`][alc-docs], or ALC. If you've never had a reason to reach for it, here's the two-minute version.

Normally every assembly your app loads goes into one big shared bucket, the default load context. ALC lets you create additional, isolated buckets. Two different contexts can each load an assembly with the same name, even different versions of it, and the runtime treats them as genuinely separate. Worth being precise about "isolated" though, because it isn't a sandbox. There's no binary isolation between contexts, they're only isolated by not finding each other by name.

And things get weird when you start sharing types across contexts.

## Standing on Uno Studio's Shoulders

I did not invent the hard part here. The [Uno Platform Studio][uno-studio] tooling, and [Hot Design][hot-design] in particular, already hosts your live, running app so it can turn it into a designer. That plumbing is exactly this: loading and running an app inside another process's world. The Uno 6.7-dev runtime exposes the pieces that make it work as public API, and I just wired them together for a much simpler purpose.

There are really only three moving parts, and the nicest surprise was that the main path needs zero reflection into Uno internals:

- `AlcContentHost`, a `ContentControl` you drop into your visual tree to reserve a spot for the guest.
- `WindowHelper.ContentHostOverride`, which you point at that host so a guest's window content gets redirected into it instead of trying to open its own native window.
- A second `UnoPlatformHostBuilder`, which you build around the guest's `Application` and run.

## The Host Side

On the wrapper's main page, I create the content host once and register it as the override for the whole app's lifetime:

```csharp
_contentHost = new AlcContentHost { HorizontalAlignment = HorizontalAlignment.Stretch };
GuestRegion.Child = _contentHost;

// Redirect any hosted guest's window into our region.
WindowHelper.ContentHostOverride = _contentHost;
```

When you pick a theme, the loader creates a fresh collectible ALC, loads the guest's assemblies into it, and starts the guest with its own host builder. The important subtlety is what gets shared versus isolated. The Uno framework assemblies (`Uno.UI` and friends) are shared from the default context, because if the host and the guest each loaded their own `Uno.UI`, their types would not be the same types and nothing would line up. The guest's own code and its theme library, on the other hand, stay fully isolated inside the collectible context. That whole shared-versus-isolated policy now lives in a single data file that both the loader and the build step read, so the runtime and the packaging can never quietly drift apart, a subtlety that bit me until I collapsed the two lists into one.

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

From there the guest constructs its `App`, sets up its window, and Uno quietly redirects that window's content into the `AlcContentHost`. The guest thinks it's a normal top-level app. It has no idea it's a guest.

## Two Tiny Changes to Each Guest

The coolest part is how little the sample apps had to change to become hostable. Exactly two things, and both are one-liners.

First, one property in the csproj so the XAML generator knows this app might be hosted and scopes its resource dictionaries to the right load context. Basically, this is how we can ensure that the guest's static resources don't leak into the host's world, and vice versa. Add this to the guest's csproj:

```xml
<UnoEnableAlcAppSupport>true</UnoEnableAlcAppSupport>
```

Second, and this one is a genuine gotcha, the sample apps used to grab their window like this:

```csharp
MainWindow = Microsoft.UI.Xaml.Window.Current;
```

`Window.Current` is a process-wide static living in the shared `Uno.UI`. When the app runs hosted, that static is the wrapper's window, so the guest would reach up and grab the host's window and promptly try to close it. The fix is to just make a new one:

```csharp
MainWindow = new Microsoft.UI.Xaml.Window();
```

That's still correct when the app runs standalone, because the first `new Window()` maps to the main window anyway. So the sample heads stay completely standalone. They gained the ability to be hosted without giving up the ability to run on their own.

## Guest overstaying their welcome

This was the question I most wanted to answer, because a memory leak per theme switch would make the whole thing a toy.

On desktop under X11, I ran a Release soak test that loads, switches, unloads, and reloads across all three guests for sixteen cycles. The previous guest's load context was collected fifteen out of fifteen times, and the managed heap stayed flat at around 32 MB the whole way through. On the managed side, this genuinely works. The collectible ALC does its job and the memory comes back. After a couple of rounds of internal architecture review, that check is now wired into CI as a hosting smoke test: every build loads all three guests, unloads them, and asserts that each load context was actually reclaimed. If a future change starts leaking, the build fails instead of the leak sneaking through.

### The teardown dance

Getting to fifteen out of fifteen took more than calling `Unload()`. Unloading is cooperative, so it only finishes once nothing outside the context still points at anything inside it, and the awkward part is that guest finalizers keep running *during* the unload and can put things back after you've cleaned up. The [sequence I landed on][teardown] is:

```csharp
// 7. Drop every session reference before unloading so the collectible ALC can go.
var alc = session.Alc;
session.GuestApp = null;
session.ExecutionTask = null;
session.ExecutionThread = null;

await Task.Run(alc.Dispose).ConfigureAwait(false);
_lastUnloadedAlc = new WeakReference<GuestAssemblyLoadContext>(alc);

GC.Collect();
await DrainFinalizersAsync().ConfigureAwait(false);
await RunOnUIThreadAsync(SweepNonDefaultAlcCaches).ConfigureAwait(false);

GC.Collect();
```

Drop the references, unload, let the finalizers drain, and only then sweep. Sweeping before the finalizers finish just means they refill the caches behind you.

### The sweeps

That `SweepNonDefaultAlcCaches` call is the honest ugly part. It's three reflection-based pokes at Uno internals, deliberately parked in [one file][sweeps] so they're easy to delete later, and every one of them degrades to a logged warning rather than an exception if a future Uno rename moves the target:

- **[Re-running Uno's own cache sweep][sweep-finalizers].** `ExitAlcApplication()` already clears the per-ALC static caches, but guest `DependencyObject` finalizers run afterwards and can re-populate them. I invoke `Application.CleanupNonDefaultAlcCaches` a second time once the finalizers have drained. ([uno#24075][issue-finalizers])
- **[Clearing `DependencyProperty._getPropertyCache`][sweep-dp].** This one took a heap dump to find. That cache memoizes `(targetType, "ns:Owner.Property")` lookups, and a guest style targeting an attached property on a framework element caches a *default-ALC* key with a *guest-ALC* value. Uno's per-key sweep only checks the key, so the entry survives and roots the guest's `LoaderAllocator` forever. ([uno#24073][issue-dp])
- **[Pruning `SystemNavigationManager` handlers][sweep-nav].** The samples' `Shell` subscribes to the process-wide `BackRequested` and nothing unsubscribes it on teardown, so the stale handler roots the guest's entire visual tree ([uno#24074][issue-nav]). The fix is to walk the invocation list and drop anything whose origin lives in a collectible context:

```csharp
var originAssembly = handler.Target?.GetType().Assembly ?? handler.Method.Module.Assembly;
var targetAlc = AssemblyLoadContext.GetLoadContext(originAssembly);
if (targetAlc is not null && targetAlc != AssemblyLoadContext.Default)
{
    pruned = Delegate.Remove(pruned, handler);
}
```

None of this is exotic, it's the direct cost of sharing `Uno.UI` from the default context. Every shared assembly is non-collectible code that can hold a reference into the guest, and one static still pointing at a guest object roots the whole load context. The sweeps aren't really a workaround bolted on the side, they're the counterpart to sharing anything at all.

### The parts that don't clean up

I'll be honest about those too, because this is running on a 6.7-dev build and it shows. There's a native leak: each guest window create and destroy cycle leaks its native GL context on X11, somewhere around 12 to 15 MB a cycle, even though the managed side is fully reclaimed ([uno#24076][issue-x11]). Every one of these is now filed upstream with a repro and a suggested fix, so they're tracked deficiencies with a shelf life rather than mystery hacks, and each sweep deletes itself the day its fix ships. And by design, this hosts exactly one guest at a time. It started as a "wouldn't it be funny" experiment, it's had a real hardening pass since, but it still rides on a preview runtime and I want to be upfront about that.

---
The direction that matters

Guest → host references are fine. Host → guest is what kills you. A non-collectible root reaching into collectible memory.

With one exception the docs call out explicitly: strong GC handles block unload "from both inside and outside." A GCHandle.Alloc made by guest code, pointing at a guest object, prevents its own context from unloading — because a GC handle is a root regardless of who created it.

Where this bites your app specifically

Your shared-vs-isolated split is also your leak surface. Every assembly shared from Default is non-collectible code that might hold a guest reference. The highest-risk vector is statics in the shared Uno.UI — anything like Application.Current, or a resource-dictionary cache, still pointing at the guest's App instance after teardown roots the entire context. That's precisely what your reflection-based cache sweeping at :132 is doing, and framing it that way makes it read less like a hack and more like the mandatory counterpart to sharing Uno.UI at all.
---


## Why Bother

Beyond it just being cool, there's a real payoff. The Uno.Themes repo deploys a staging site for every pull request, and it used to only cover the Simple theme. This wrapper now lets one deployment host all three theme samples behind a picker, so every PR gets a single staging site that covers Material, Cupertino, and Simple at once. The fun demo turned into an actual improvement to how we test the themes.

There's also something I like about pulling back the curtain. The ALC hosting that powers Hot Design can feel like magic when it's buried inside a product. Wiring it up myself, and hitting all the sharp edges, made it a lot less magical and a lot more approachable. If you want to see the whole thing, warts and workarounds included, all of the code is in the [pull request][pr].

I should also mention I built this alongside an agent, using Claude Code, which fits right in with the [agentic development]({% post_url 2026-02-23-agent-skills-intro %}) thread I've been on lately. Chasing down a trimmer stripping type-forwarders is exactly the kind of deep, weird problem where having a tireless pair helps.

## Conclusion

So there it is. Uno apps running inside Uno apps, one collectible load context at a time, built on the same runtime plumbing that Uno Platform Studio uses in production. It started as a "wouldn't it be funny if" and turned into both a genuine testing improvement and the most I've learned about `AssemblyLoadContext` in one sitting.

If you go try something like this yourself, do it on a 6.7 build and expect to get friendly with load contexts. And if you build something sillier than a SUPER THEMES APP, please come show me in the [Uno Discord][uno-discord].

Catch you in the next one :wave:

<i>*</i> We are still hunting down some leaks, we've made good progress but memory management is hard ok? Give us a break.

[tweet]: https://x.com/BiloganSteve/status/2087173345322152018
[uno-discord]: https://platform.uno/discord
[pr]: https://github.com/unoplatform/Uno.Themes/pull/1693
[alc-docs]: https://learn.microsoft.com/en-us/dotnet/core/dependency-loading/understanding-assemblyloadcontext
[alc-unloadable]: https://learn.microsoft.com/en-us/dotnet/standard/assembly/unloadability
[r2r]: https://learn.microsoft.com/en-us/dotnet/core/deploying/ready-to-run
[uno-studio]: https://platform.uno/studio/
[hot-design]: https://platform.uno/docs/articles/studio/Hot%20Design/hot-design-overview.html
[uno-themes]: https://github.com/unoplatform/Uno.Themes
[teardown]: https://github.com/unoplatform/Uno.Themes/blob/f31c03fa4dfc59749bdeb67bf4f1f80b45e8f4ae/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.cs#L459-L480
[sweeps]: https://github.com/unoplatform/Uno.Themes/blob/f31c03fa4dfc59749bdeb67bf4f1f80b45e8f4ae/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs
[sweep-finalizers]: https://github.com/unoplatform/Uno.Themes/blob/f31c03fa4dfc59749bdeb67bf4f1f80b45e8f4ae/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs#L19-L21
[sweep-dp]: https://github.com/unoplatform/Uno.Themes/blob/f31c03fa4dfc59749bdeb67bf4f1f80b45e8f4ae/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs#L23-L35
[sweep-nav]: https://github.com/unoplatform/Uno.Themes/blob/f31c03fa4dfc59749bdeb67bf4f1f80b45e8f4ae/src/samples/ThemesSampleApp/GuestHosting/GuestAppLoader.Sweeps.cs#L100-L158
[issue-dp]: https://github.com/unoplatform/uno/issues/24073
[issue-nav]: https://github.com/unoplatform/uno/issues/24074
[issue-finalizers]: https://github.com/unoplatform/uno/issues/24075
[issue-x11]: https://github.com/unoplatform/uno/issues/24076
{% include links.md %}
