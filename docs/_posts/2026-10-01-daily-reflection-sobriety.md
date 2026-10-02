---
title: "One Day at a Time - Rebuilding Daily Reflection"
category: uno-general
header:
  teaser: /assets/images/daily-reflection/hero.png
  og_image: /assets/images/daily-reflection/hero.png
tags: [personal, recovery, sobriety, daily-reflection, xamarin, maui, uno-platform, uno, mvux, agents, migration]
---

This one is going to be a little different.

I usually write about Uno Platform, controls, and lately a lot about agentic development. Today I want to write about something more personal and then tie it back to the code, because for me the two have always been tangled together. I'm in recovery. I'm sober and clean from alcohol and drugs, and that fact sits underneath a lot of who I am, including the developer part.

I'm not going to lay out my whole story here, at least not today. That part is mine to tell in my own time. But a piece of it lives in a public GitHub repo and on two app stores, and it feels right to finally talk about it. It's a little app called Daily Reflection. I've spent the better part of a year rebuilding it, and version 4 is now officially out. So let's talk about the app, how I built it the first time, and how it got rebuilt on Uno Platform with a lot of help from AI agents.

## The App I Never Blog About

Daily Reflection is a small, quiet app that does three things.

It shows you a daily reading. The content comes from the book Daily Reflections, a collection of daily meditations written by A.A. members for A.A. members. Each day has a title, a quote from A.A. literature, and a short first-person reflection. There are 366 of them, one for every day of the year including February 29.

It counts your sober time. You set the date you got sober and the app tells you how long it's been, either in years, months, and days, or just in days if that's how you like to count it. At the bottom of that screen is a single line: "One day at a time."

And it reminds you, with an optional daily notification so the reading shows up at a time that works for you.

<figure>
    <a href="/assets/images/daily-reflection/original-screens.png" class="image-popup"><img class="align-center" src="/assets/images/daily-reflection/original-screens.png" alt="The original 2020 Daily Reflection app showing the reading screen and the sober-time screen on iOS"/></a>
</figure>

That's the 2020 version above, and it's the whole app. It's on the [App Store][app-store] as "AA Daily Reflection" and on [Google Play][play-store]. No accounts, no backend, no analytics, no tracking. The tagline on the store graphic is "Recovery, Unity, Service." It's the least commercial thing I've ever shipped and the one I'm most attached to, because reading a daily reflection and counting my time are two small rituals that keep me grounded. I wanted them in my pocket, and I figured if they helped me they might help someone else in the rooms too.

## How I Built It Back in 2020

I first built Daily Reflection in the fall of 2020, and I built it the way I built everything back then: Xamarin.Forms. Specifically Xamarin.Forms 4.8, with the Material visual applied across the app and Shell handling the three-tab navigation.

Even though it's tiny, I gave it a real layered architecture, because I wanted it testable and I wanted to enjoy working on it. There were four shared `netstandard2.0` libraries:

- **Core**: constants and small helpers, like the `StripHtml` extension that cleans up the reading text.
- **Data**: the reflection model and database access.
- **Services**: the business layer, wrapping data and platform features behind interfaces.
- **Presentation**: the view models, messages, and everything the UI binds to.

A couple of decisions from back then that I'm still happy with. The content ships as an embedded, read-only SQLite database: all 366 reflections baked into the app as a resource, copied out on first launch and queried by month and day. No network, ever. The app works on a plane or in a basement meeting. And for the sober-time math I leaned on [NodaTime][nodatime], because "how many years, months, and days between these two dates" is exactly the kind of question that looks trivial and absolutely is not.

The part I was proudest of was the dependency injection. I ran the full .NET Generic Host inside a Xamarin app, wiring it up in `Startup.cs` roughly like this:

```csharp
Host.CreateDefaultBuilder()
    .ConfigureServices(services => services
        .AddCoreServices()
        .AddDataServices()
        .AddAppServices()
        .AddPresentation()
        .AddPages())
    .Build();
```

To keep the view models testable I wrapped the platform bits behind interfaces with `Xamarin.Essentials.Interfaces`, and there were NUnit and Moq unit tests plus Xamarin.UITest UI tests. Notifications were the one genuinely platform-specific piece, hidden behind an `INotificationService`. The whole thing built and signed itself through Azure Pipelines.

It got a few small fixes over the next couple of years, and then, honestly, it mostly sat there. It worked, so I stopped touching it.

## Xamarin Caught Up With Me

Xamarin is end of life. The tooling moved on, and a codebase pinned to Xamarin.Forms 4.8 is a codebase on borrowed time. My little recovery app was quietly rotting on a foundation the rest of the ecosystem had already left behind. So about a year ago I decided to give it a proper modern foundation, and to do it in a way that would teach me something.

## The Pilot

I didn't touch the original repo at first. Instead I set up a [second repository][gh-daily-reflection-ports] as a multi-head monorepo. The four shared libraries moved up to `net10.0` almost unchanged, and on top of them I added a .NET MAUI head, an Uno Platform head, and an Avalonia head that I spun up mostly out of curiosity. The Xamarin app stayed in as a git submodule for reference, and each head got its own bundle ID so I could install them right next to the original on the same phone.

That repo was never meant to be the product. It was a pilot. Because the same view models drove both the MAUI and Uno heads, it turned into a really honest comparison, and the differences all lived in a thin layer:

- **Navigation.** MAUI leans on Shell. Uno doesn't have it, so the Uno head used Uno.Extensions navigation regions together with the Toolkit `TabBar`.
- **Rendering the readings.** The reading text has a little HTML in it, italics and line breaks. MAUI renders that natively with `Label TextType="Html"`. Uno's `TextBlock` doesn't do HTML, so the Uno head parses the markup into `Run` and `LineBreak` inlines.

What stayed exactly the same is the part I find most encouraging. The business logic didn't care which UI framework sat on top of it. That's the payoff for having drawn those layers cleanly back in 2020.

## Letting the Agents Do the Migration

Here's where it connects to what I've been writing about lately. I did not port this app by hand. I drove the migration with AI agents, and I set it up deliberately so I could watch how well that works on a real, if small, production codebase.

The migration brief lives in the repo as [`prompt.md`][gh-prompt]. It's strict on purpose. The two rules I cared about most:

> Uno Platform Docs MCP must be queried before every decision.
>
> Do not delete or modify the original MAUI project.

Don't guess, look it up, and don't break the thing that already works. It's the same idea from my [Agent Skills post]({% post_url 2026-02-23-agent-skills-intro %}), pointed at a migration instead of a feature.

I ran the first pass, the mechanical MAUI to Uno migration, with GitHub Copilot driving and the Uno Docs MCP as its source of truth. The full transcript is committed as a `genlog.md`, and it's a fascinating read. That got me a compiling Uno app. But compiling is not the same as correct.

So for the second pass I brought in Claude Code and gave it a different job: be adversarial. It read all three implementations and wrote a gap analysis with a twenty-item punch list. Version tracking that hadn't carried over. HTML emphasis in the readings getting flattened. A share action with a race condition. The unglamorous drift a mechanical port always leaves behind. Then I had it work that list down, one small spec at a time, eleven of them in all.

In late July the Uno head moved into the original repo, and that was the real turning point. One pull request, 273 files, and the Xamarin heads were gone. It kept the original bundle ID, so the stores see the new app as an update to the old one instead of a brand new listing.

I did have to write a rule for the agents along the way. The repo's `AGENTS.md` now opens with a hard rule: never bypass branch protection with admin rights. Branch, pull request, green checks, and I do the merging. I wrote it after I pushed a workflow fix straight to `master` myself, because my account is allowed to. If I can trip over that loophole, an agent certainly can.

## What Actually Shipped

The final app is one multi-targeted Uno project. It builds for Android, iOS, desktop, and WebAssembly, all rendered with Skia. The shared libraries still don't have a single platform `#if` in them, because everything platform-specific lives in the head.

A few things changed along the way that I'm quite happy with.

**MVUX replaced the MVVM Toolkit.** The old view models are now `partial record` models exposing feeds and states. The Sober Time tab derives its years, months, and days from a single sober date feed, and NodaTime is still doing the date math underneath. Some things you just don't rewrite.

**The color palette comes from a single seed.** There's no hand-written Light and Dark color file in this app. Uno Material generates the whole palette from the blue the Xamarin app used:

```xml
<MaterialToolkitTheme xmlns="using:Uno.Toolkit.UI.Material"
                      xmlns:ut="using:Uno.Themes">
    <MaterialToolkitTheme.Colors>
        <ut:ThemeColors PrimarySeed="#1976D2" />
    </MaterialToolkitTheme.Colors>
</MaterialToolkitTheme>
```

That's the [seed color feature][seed-colors-docs] in Uno.Themes doing exactly what it promises. The generated roles sit at Material 3 tone levels, so the primary isn't literally `#1976D2` anymore. If you need an exact value, you override that role.

**The shell is responsive.** The Xamarin app was phone-only, so desktop never needed an answer before. On narrow windows you get the bottom `TabBar`. From 700px up, you get a vertical rail on the left. Both bars live in the visual tree at the same time and the Toolkit's `Responsive` markup extension flips their visibility:

```xml
<utu:ResponsiveLayout x:Key="ShellResponsiveLayout"
                      Narrow="0"
                      Normal="700" />

<utu:TabBar x:Name="SideTabs"
            Style="{StaticResource VerticalTabBarStyle}"
            Visibility="{utu:Responsive Layout={StaticResource ShellResponsiveLayout},
                                        Narrow=Collapsed,
                                        Normal=Visible}">
    ...
</utu:TabBar>
```

I tried `NavigationView` first, since it's the obvious choice, and it fought the Material style. Two `TabBar`s sharing one navigation region won.

**Your sober date survives the upgrade.** This is the one I care about most. On the first launch after updating, the app imports your sober date, notification time, and display preference from the old Xamarin app's storage. The first version of that import was gated on a version number, and the old check parsed `4.0.N` as zero. So it would have quietly never run. It now keys off a flag that only gets set after the import succeeds, and there are tests using the exact version strings the app actually ships.

## Getting It to the Stores

Azure Pipelines is gone, replaced by GitHub Actions. A push to a `release/*` branch builds signed Android and iOS packages plus desktop zips, then waits for my manual approval. Only after I click the button does it submit to App Store Connect, upload to Google Play, and cut the GitHub release. Every merge to `master` that touches app code also ships a signed build to the Play internal track and TestFlight, with no approval, so problems show up on a device and not in a store submission.

The Android and iOS store packages are Native AOT, which landed in Uno Platform 6.6. The [Native AOT docs][native-aot-docs] are the place to start if you're curious.

I'd love to tell you the first release went smoothly. It did not. There were a handful of pre-releases first. Then the App Store refused the 4.0.36 submission because the release notes weren't going to the right localization. After that, Google Play flagged 4.0.37 for an unshrunk DEX file, so 4.0.39 turns on R8 and takes the code from roughly 11 MB down to about 4 MB. Each of those was a small fix, but they all had to land before the stable releases could go out. And they're out now.

## What's New in Version 4

The short version for users is that everything carries over, and there's one new thing. If you had the daily reminder on, you might be asked to allow notifications again.

<figure>
    <a href="/assets/images/daily-reflection/new-screens.png" class="image-popup"><img class="align-center" src="/assets/images/daily-reflection/new-screens.png" alt="The rebuilt Daily Reflection app on iOS, showing the reading screen on the left and the secular reading on the right, with the Material bottom tab bar"/></a>
</figure>

The new thing is Secular Readings. Flip a switch in Settings and the app reads from *Beyond Belief: Agnostic Musings for 12 Step Life* instead of Daily Reflections. That's the second screen above. There are also new date and time pickers, and an About link in Settings.

## The Rough Edges

I want to be honest about what isn't finished, because nobody wins by me pretending otherwise.

- On Skia desktop, content that changes while its tab is hidden can show stale rendering after you switch back. I tried several workarounds and none of them worked. It's tracked in [an Uno issue][uno-24768].
- Android Native AOT is still flagged experimental by the .NET for Android SDK. Uno documents it and ships it, and the pipeline has a switch to fall back if I ever need to.
- Desktop notifications aren't supported on macOS and Linux, and the desktop zips are unsigned. The macOS build isn't notarized.

The MAUI and Avalonia heads stayed in the pilot repo. They did their job, which was to teach me something.

## What Recovery Taught Me About Shipping Software

I said at the top that the two are tangled together, so let me close there.

One day at a time is not a low bar. It's an admission that the only unit of progress you actually control is today's. You can't ship the whole rebuild today, but you can migrate one screen, close one gap, get one more test green. String enough of those together and you look up and the thing is real.

The first Uno build was ugly: flattened text, missing features, a race condition. The old me, in code and out of it, would have either called it done because it compiled or thrown the whole thing out because it wasn't perfect. Recovery taught me the version in between. It's allowed to be ugly, and you're allowed to keep working it. Write the gaps down honestly, then close them one at a time.

And I didn't rebuild this alone. A few years ago I'd have insisted on doing every line by hand out of stubbornness. Handing the grunt work to the agents and the Uno docs while keeping the decisions for myself is a version of asking for help I can actually stomach, and it's one I had to learn as a person long before I learned it in a codebase.

## Conclusion

Daily Reflection is a tiny app. It'll never top a chart and it was never supposed to. But it's the truest thing I've built, because it came straight out of the practice that keeps me well, and rebuilding it has quietly become its own kind of practice.

If you're a developer sitting on an aging Xamarin app, I'd genuinely encourage you to try driving a migration with an agent and a docs MCP. It's a great way to learn where these tools shine and where they still need a human. And if you happen to need a daily reading and a day counter in your pocket, version 4 is right there.

If any of the recovery part of this resonated with you, my inbox and the [Uno Discord][uno-discord] are always open. You're not alone in it.

One day at a time. Catch you in the next one :wave:

## Additional Resources

- [Daily Reflection on GitHub][gh-daily-reflection]
- [The pilot repo (MAUI, Uno, Avalonia)][gh-daily-reflection-ports]
- [AA Daily Reflection on the App Store][app-store]
- [Daily Reflection on Google Play][play-store]
- [Uno Platform Native AOT][native-aot-docs]
- [Seed Color Palette Generation][seed-colors-docs]

[gh-daily-reflection]: https://github.com/kazo0/DailyReflection
[gh-daily-reflection-ports]: https://github.com/kazo0/DailyReflection-ports
[gh-prompt]: https://github.com/kazo0/DailyReflection/blob/a6b8e56/prompt.md
[app-store]: https://apps.apple.com/us/app/aa-daily-reflection/id1536494178
[play-store]: https://play.google.com/store/apps/details?id=com.kazo0.dailyreflection
[nodatime]: https://nodatime.org/
[native-aot-docs]: https://platform.uno/docs/articles/features/native-aot.html
[seed-colors-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/seed-colors.html
[uno-24768]: https://github.com/unoplatform/uno/issues/24768
[uno-discord]: https://platform.uno/discord
{% include links.md %}
