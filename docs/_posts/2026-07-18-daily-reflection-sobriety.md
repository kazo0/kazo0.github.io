---
title: "One Day at a Time: Sobriety, Code, and Rebuilding Daily Reflection"
category: uno-general
header:
  teaser: /assets/images/daily-reflection/hero.png
  og_image: /assets/images/daily-reflection/hero.png
tags: [personal, recovery, sobriety, daily-reflection, xamarin, maui, uno-platform, uno, agents, migration]
---

This one is going to be a little different.

I usually write about Uno Platform, controls, and lately a lot about agentic development. Today I want to write about something more personal and then tie it back to the code, because for me the two have always been tangled together. I'm in recovery. I'm sober and clean from alcohol and drugs, and that fact sits underneath a lot of who I am, including the developer part.

I'm not going to lay out my whole story here, at least not today. That part is mine to tell in my own time. But a piece of it lives in a public GitHub repo and on two app stores, and it feels right to finally talk about it. It's a little app called Daily Reflection, and I've just spent a good chunk of the last year rebuilding it. So let's talk about the app, how I built it, and how I'm rebuilding it on Uno Platform and .NET MAUI with a lot of help from AI agents.

## The App I Never Blog About

Daily Reflection is a small, quiet app that does three things.

It shows you a daily reading. The content comes from the book [Daily Reflections][gh-daily-reflection], a collection of daily meditations written by A.A. members for A.A. members. Each day has a title, a quote from A.A. literature, and a short first-person reflection. There are 366 of them, one for every day of the year including February 29.

It counts your sober time. You set the date you got sober and the app tells you how long it's been, either in years, months, and days, or just in days if that's how you like to count it. At the bottom of that screen is a single line: "One day at a time."

And it reminds you, with an optional daily notification so the reading shows up at a time that works for you.

<a href="/assets/images/daily-reflection/original-screens.png"><img class="align-center" src="/assets/images/daily-reflection/original-screens.png" alt="The original Daily Reflection app showing the reading screen and the sober-time screen on iOS"/></a>

That's the whole app. It's on the [App Store][app-store] as "AA Daily Reflection" and on [Google Play][play-store]. No accounts, no backend, no analytics, no ads. The tagline on the store graphic is "Recovery, Unity, Service." It's the least commercial thing I've ever shipped and the one I'm most attached to, because reading a daily reflection and counting my time are two small rituals that keep me grounded. I wanted them in my pocket, and I figured if they helped me they might help someone else in the rooms too.

## How I Built It Back in 2020

I first built Daily Reflection in the fall of 2020, and I built it the way I built everything back then: [Xamarin.Forms][gh-daily-reflection]. Specifically Xamarin.Forms 4.8, with the Material visual applied across the app and Shell handling the three-tab navigation.

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

Each layer contributed its own registrations. To keep the view models testable I wrapped the platform bits behind interfaces with `Xamarin.Essentials.Interfaces`, and there were unit tests with NUnit and Moq plus a set of Xamarin.UITest UI tests. Notifications were the one genuinely platform-specific piece, hidden behind an `INotificationService`: `AlarmManager` and a broadcast receiver on Android, `UNUserNotificationCenter` on iOS. The whole thing built and signed itself through Azure Pipelines.

It got to version 3.4, and then, honestly, it mostly sat there. It worked, so I stopped touching it.

## Xamarin Caught Up With Me

Xamarin is end of life. The tooling moved on, and a codebase pinned to Xamarin.Forms 4.8 is a codebase on borrowed time. My little recovery app was quietly rotting on a foundation the rest of the ecosystem had already left behind. So late last year I decided to give it a proper modern foundation, and to do it in a way that would teach me something.

## One Codebase, Three Faces

Instead of just porting the app once, I set up a [second repository][gh-daily-reflection-ports] as a multi-head monorepo. The idea: keep all of that shared business logic exactly as it was and stand it up on more than one modern UI stack at the same time.

The four shared libraries moved up to `net10.0` almost unchanged. The view models, the messages, the embedded database, the NodaTime math, all of it carried straight over. On top of that shared core I added platform "heads":

- A **.NET MAUI** head, the natural successor to Xamarin.Forms.
- An **Uno Platform** head, targeting Android, iOS, and desktop.
- An **Avalonia** head that I spun up mostly out of curiosity. It's still a work in progress.

The original Xamarin app stays in the repo too, pinned as a git submodule, as a reference and a fallback. Everything is organized with a `.slnx` solution and a pair of solution filters, `DailyReflection-uno.slnf` and `DailyReflection-maui.slnf`, so I can build one head plus the shared libraries in isolation. Each head gets its own bundle ID, so I can install the Uno build right next to the original on the same phone.

The whole point is that the interesting differences live in a thin layer. If I did it right, the same view model drives the same screen on MAUI and on Uno, and only the XAML and platform glue change underneath. That turned out to be almost exactly true, and the "almost" is where all the good learning was.

## Letting the Agents Do the Migration

Here's where it connects to what I've been writing about lately. I did not port this app by hand. I drove the migration with AI agents, and I set it up deliberately so I could watch how well that works on a real, if small, production codebase.

The migration brief lives in the repo as a `prompt.md`. It's strict on purpose. The two rules I cared about most:

> Uno Platform Docs MCP must be queried before every decision.
>
> Do not delete or modify the original MAUI project.

Don't guess, look it up, and don't break the thing that already works. It's the same idea from my [Agent Skills post]({% post_url 2026-02-23-agent-skills-intro %}), pointed at a migration instead of a feature. Every time the agent wanted to swap a MAUI control for its Uno equivalent, it had to consult the Uno docs through the MCP and cite the answer.

I ran the first pass, the mechanical MAUI to Uno migration, with GitHub Copilot driving and the Uno Docs MCP as its source of truth. The full transcript is committed as a `genlog.md`, and it's a fascinating read. One of the migrated pages even carries a header comment recording the mechanical mapping it applied:

```text
ContentPage → Page, StackLayout → StackPanel, Label → TextBlock,
ActivityIndicator → ProgressRing, ToolbarItems → CommandBar
```

That got me a compiling Uno app. But compiling is not the same as correct. So for the second pass I brought in Claude Code and gave it a different job: be adversarial. It read all three implementations, the Xamarin original, the MAUI port, and the new Uno port, and produced a gap analysis cataloguing around ninety differences ranked by severity. Version tracking that hadn't carried over. HTML emphasis in the readings getting flattened. A share action with a race condition. Missing automation IDs. The unglamorous drift a mechanical port always leaves behind.

Then I had it work that list down, one small spec at a time. There are eleven numbered specs in the repo, each tied back to specific gaps, each with acceptance criteria and a "done when" checklist. By the end there were 48 passing unit tests across the services and presentation layers, green on `net10.0`. The whole thing ran inside a locked-down dev container with read-only tokens and a DNS allowlist that refuses any domain I didn't explicitly permit. If I'm going to let an agent run for a long time on my code, I want it boxed in. That setup probably deserves its own post.

## MAUI and Uno, Side by Side

Because the same view models drive both heads, the ports became an honest comparison of the two frameworks. The shared code stayed identical, and each head diverged only where the platform genuinely demanded it.

Navigation was the biggest divergence. MAUI leans on Shell, so the shell is a compact tree of tabs:

```xml
<Shell>
    <TabBar>
        <Tab Title="Reflection" ... />
        <Tab Title="Sober Time" ... />
        <Tab Title="Settings" ... />
    </TabBar>
</Shell>
```

Uno doesn't use Shell. The Uno head uses Uno.Extensions navigation regions together with the Toolkit `TabBar`, the exact pattern I walked through in my Uno Chefs series: an outer grid is a region, an inner grid swaps its content by visibility, and each tab item maps to a named route.

```xml
<Grid uen:Region.Attached="True">
    <Grid uen:Region.Navigator="Visibility" />
    <utu:TabBar>
        <utu:TabBarItem uen:Region.Name="Reflection" ... />
        <utu:TabBarItem uen:Region.Name="SoberTime" ... />
        <utu:TabBarItem uen:Region.Name="Settings" ... />
    </utu:TabBar>
</Grid>
```

A few more differences worth calling out:

- **Rendering the readings.** The reading text has a little HTML in it, italics and line breaks. MAUI renders that natively with `Label TextType="Html"`. Uno's `TextBlock` doesn't do HTML, so the Uno head parses the markup in code-behind into `Run` and `LineBreak` inlines. That was one of the gaps the analysis caught.
- **The settings screen.** MAUI has a native `TableView`. WinUI, and therefore Uno, has none, so the settings page is rebuilt as a hand-laid grid of cards using `ToggleSwitch`, `ComboBox`, and the WinUI date and time pickers.
- **Preferences and sharing.** MAUI uses `Preferences.Default` and `Share.Default`. Uno uses `ApplicationData.LocalSettings` and the `DataTransferManager`, with an extra wrinkle: the Android alarm receivers need the sober date, so the Uno head mirrors it into Android `SharedPreferences` too.

What stayed exactly the same is the part I find most encouraging: the shared libraries, all three view models, the messages, the embedded database, and the whole three-tab experience. The business logic didn't care which UI framework sat on top of it. That's the payoff for having drawn those layers cleanly five years ago.

## Being Honest About Where It Stands

In the spirit of not overselling: the ports are code-complete for parity with the original, and the shared logic is well covered by those 48 tests. But the agents got it to "the tests pass," not to "I've shipped this to my own phone and lived on it for a week." Running the Uno and MAUI builds on real devices and actually trusting my daily reading to them is still on my list, and it's the part no test suite can sign off for me. On desktop, the notification service is a deliberate no-op for now. And the Avalonia head is still an experiment more than a port.

So it's not done. It's further along than it's ever been, on a foundation that will actually last, and I know exactly what the next thing to do is.

## What Recovery Taught Me About Shipping Software

I said at the top that the two are tangled together, so let me close there.

One day at a time is not a low bar. It's an admission that the only unit of progress you actually control is today's. You can't ship the whole rebuild today, but you can migrate one screen, close one gap, get one more test green. String enough of those together and you look up and the thing is real.

The first Uno build was ugly: flattened text, missing features, a race condition. The old me, in code and out of it, would have either called it done because it compiled or thrown the whole thing out because it wasn't perfect. Recovery taught me the version in between. It's allowed to be ugly, and you're allowed to keep working it. Write the gaps down honestly, then close them one at a time.

And I didn't rebuild this alone. Five years ago I'd have insisted on doing every line by hand out of stubbornness. Handing the grunt work to the agents and the Uno docs while keeping the decisions for myself is a version of asking for help I can actually stomach, and it's one I had to learn as a person long before I learned it in a codebase.

## Conclusion

Daily Reflection is a tiny app. It'll never top a chart and it was never supposed to. But it's the truest thing I've built, because it came straight out of the practice that keeps me well, and rebuilding it has quietly become its own kind of practice.

If you're a developer sitting on an aging Xamarin app, I'd genuinely encourage you to try driving a migration with an agent and a docs MCP. It's a great way to learn where these tools shine and where they still need a human. And if you happen to need a daily reading and a day counter in your pocket, the app is right there, and it's free.

If any of the recovery part of this resonated with you, my inbox and the [Uno Discord][uno-discord] are always open. You're not alone in it.

One day at a time. Catch you in the next one :wave:

## Additional Resources

- [Daily Reflection (original) on GitHub][gh-daily-reflection]
- [Daily Reflection ports (MAUI, Uno, Avalonia) on GitHub][gh-daily-reflection-ports]
- [AA Daily Reflection on the App Store][app-store]
- [Daily Reflection on Google Play][play-store]

[gh-daily-reflection]: https://github.com/kazo0/DailyReflection
[gh-daily-reflection-ports]: https://github.com/kazo0/DailyReflection-ports
[app-store]: https://apps.apple.com/us/app/aa-daily-reflection/id1536494178
[play-store]: https://play.google.com/store/apps/details?id=com.kazo0.dailyreflection
[nodatime]: https://nodatime.org/
{% include links.md %}
