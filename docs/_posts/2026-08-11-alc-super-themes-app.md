---
title: "Uno Apps Inside Uno Apps: Hosting Every Theme Sample With AssemblyLoadContext"
category: uno-general
header:
  teaser: /assets/images/alc-super-themes/hero.png
  og_image: /assets/images/alc-super-themes/hero.png
tags: [uno-platform, uno, assemblyloadcontext, alc, hot-design, themes, skia, wasm]
---

I posted a fun little experiment the other day and it got more of a reaction than I expected, so I want to follow it up with the real story of how it works. Here's [the tweet][tweet]:

> Running your @UnoPlatform apps inside of your @UnoPlatform apps ;)
>
> Inspired by the plumbing of Uno Platform Studio, I thought it'd be fun to take advantage of AssemblyLoadContext to load each Uno Themes sample app inside of a new SUPER THEMES APP. Works surprisingly well!

And here's the thing actually running. One app, and I'm picking which whole other app renders inside it, live:

<video class="align-center" autoplay muted loop controls playsinline poster="/assets/images/alc-super-themes/hero.png">
  <source src="/assets/images/alc-super-themes/super-themes-demo.mp4" type="video/mp4" />
</video>

Let's get into what's going on here, because it's one of the more genuinely fun things I've built in a while, and it leans on a piece of .NET that most of us never touch directly.

## What Even Is This

The Uno.Themes repo ships three sample apps, one per design system: Material, Cupertino, and Simple. Today, testing them means launching a different sample head for each one. I wanted a single app where I could tap a button and load any of them, then unload it and load the next one.

The catch is that these aren't little user controls I'm swapping in. Each one is a complete, independent Uno application, with its own `App` class, its own resources, its own theme library, its own everything. What you're watching in that video is one Uno app hosting another entire Uno app in the same process, swapping between three of them, with a clean teardown in between. I called it the SUPER THEMES APP because I was enjoying myself.

<a href="/assets/images/alc-super-themes/themes-running.png"><img class="align-center" src="/assets/images/alc-super-themes/themes-running.png" alt="The wrapper app hosting the Material, Cupertino, and Simple theme samples one at a time, each showing an 'is running' status"/></a>

## A Quick Word on AssemblyLoadContext

The piece of .NET that makes this possible is [`AssemblyLoadContext`][alc-docs], or ALC. If you've never had a reason to reach for it, here's the two-minute version.

Normally every assembly your app loads goes into one big shared bucket, the default load context. ALC lets you create additional, isolated buckets. Two different contexts can each load an assembly with the same name, even different versions of it, and the runtime treats them as genuinely separate. It's the foundation that real plugin systems are built on.

The other half, and the half I actually cared about, is that a load context can be marked [collectible][alc-unloadable]. A collectible context can be unloaded, and once nothing is referencing anything inside it, the garbage collector reclaims all of it: the assemblies, the types, the whole works. That's the property that lets me load a guest app, run it, and then get all of that memory back before I load the next one. In theory, anyway. Getting from "in theory" to "actually collected" is most of the story below.

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

When you pick a theme, the loader creates a fresh collectible ALC, loads the guest's assemblies into it, and starts the guest with its own host builder. The important subtlety is what gets shared versus isolated. The Uno framework assemblies (`Uno.UI` and friends) are shared from the default context, because if the host and the guest each loaded their own `Uno.UI`, their types would not be the same types and nothing would line up. The guest's own code and its theme library, on the other hand, stay fully isolated inside the collectible context.

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

The part I'm happiest about is how little the sample apps had to change to become hostable. Exactly two things, and both are one-liners.

First, one property in the csproj so the XAML generator knows this app might be hosted and scopes its resource dictionaries to the right load context:

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

## Where It Got Interesting

If the story ended there it would be a suspiciously clean blog post. It did not end there, and honestly the problems were the best part. A few of my favorites.

### The factory that refused to let go

My first instinct for creating the guest was a tidy generic helper, something like `App(() => new TApp())`. It worked, and then the ALC would never unload. It turns out a `Func<TApp>` creates a shared-generic dictionary entry that pins the collectible context's loader, so the very thing I was using to start the guest was quietly holding it hostage forever. The fix was to build the factory as a non-generic `Func<Application>` with a compiled expression, so nothing generic ever touches the guest's type. That one cost me an afternoon.

### Win32 boots differently than X11

On my Linux X11 setup, a guest's run loop blocks for the guest's lifetime, which is what my loader expected. On Win32 there's a single process-wide message loop, so the guest's nested `Run()` just schedules its startup and returns immediately. My loader read that instant return as "the guest exited before it showed anything" and tore it down mid-boot. Now only a run loop that actually faults counts as a boot failure.

### Trimming ate the bridge

The WASM build was the nastiest. Guests are loaded by reflection, so the trimmer can't see them, and it stripped type-forwarders out of the framework facade assemblies because as far as it could tell nothing used them. Every guest then died the moment it called `GetTypes()`, looking for a type that no longer had a forwarding entry. The fix was to publish this one hosting app untrimmed. It's the single ugliest tradeoff in the whole thing, because untrimmed the WASM payload balloons to around 116 MB. The regular theme heads still trim normally. Only this hosting head pays the tax.

## Does It Actually Clean Up

This was the question I most wanted to answer, because a memory leak per theme switch would make the whole thing a toy.

On desktop under X11, I ran a Release soak test that loads, switches, unloads, and reloads across all three guests for sixteen cycles. The previous guest's load context was collected fifteen out of fifteen times, and the managed heap stayed flat at around 32 MB the whole way through. On the managed side, this genuinely works. The collectible ALC does its job and the memory comes back.

I'll be honest about the parts that don't, though, because this is running on a 6.7-dev build and it shows. There's a native leak: each guest window create and destroy cycle leaks its native GL context on X11, even though the managed side is fully reclaimed. There are also a few spots where I had to reach in with reflection and manually sweep some of Uno's internal caches on unload, because the current dev runtime doesn't fully clear them itself. Every one of those sweeps is a workaround with a note attached to delete it once the upstream fix lands. And by design, this hosts exactly one guest at a time. This is an experiment sitting on a preview runtime, not a shipping feature, and I want to be upfront about that.

## Why Bother

Beyond it just being cool, there's a real payoff. The Uno.Themes repo deploys a staging site for every pull request, and it used to only cover the Simple theme. This wrapper now lets one deployment host all three theme samples behind a picker, so every PR gets a single staging site that covers Material, Cupertino, and Simple at once. The fun demo turned into an actual improvement to how we test the themes.

There's also something I like about pulling back the curtain. The ALC hosting that powers Hot Design can feel like magic when it's buried inside a product. Wiring it up myself for a throwaway sample app, and hitting all the sharp edges, made it a lot less magical and a lot more approachable. If you want to see the whole thing, warts and workarounds included, all of the code is in the [pull request][pr].

I should also mention I built this alongside an agent, using Claude Code, which fits right in with the [agentic development]({% post_url 2026-02-23-agent-skills-intro %}) thread I've been on lately. Chasing down a trimmer stripping type-forwarders is exactly the kind of deep, weird problem where having a tireless pair helps.

## Conclusion

So there it is. Uno apps running inside Uno apps, one collectible load context at a time, built on the same runtime plumbing that Uno Platform Studio uses in production. It started as a "wouldn't it be funny if" and turned into both a genuine testing improvement and the most I've learned about `AssemblyLoadContext` in one sitting.

If you go try something like this yourself, do it on a 6.7 build and expect to get friendly with load contexts. And if you build something sillier than a SUPER THEMES APP, please come show me in the [Uno Discord][uno-discord].

Catch you in the next one :wave:

[tweet]: https://x.com/BiloganSteve/status/2087173345322152018
[uno-discord]: https://platform.uno/discord
[pr]: https://github.com/unoplatform/Uno.Themes/pull/1693
[alc-docs]: https://learn.microsoft.com/en-us/dotnet/api/system.runtime.loader.assemblyloadcontext
[alc-unloadable]: https://learn.microsoft.com/en-us/dotnet/standard/assembly/unloadability
[uno-studio]: https://platform.uno/uno-platform-studio/
[hot-design]: https://platform.uno/docs/articles/studio/Hot%20Design/hot-design-overview.html
{% include links.md %}
