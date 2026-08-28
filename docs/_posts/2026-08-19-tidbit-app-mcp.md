---
title: "Uno Tidbit: Giving Your Agent Eyes and Hands with the App MCP"
category: uno-tidbit
header:
  teaser: /assets/images/tidbit-hero.png
  og_image: /assets/images/tidbit-hero.png
tags: [uno-tidbits, uno-tidbit, tidbit, agents, ai, mcp, app-mcp, runtime, verification, uno-platform, uno, unoplatform]
---

Welcome to another edition of Uno Tidbits! In this series, we will be covering small, bite-sized topics that are useful to know when working with Uno Platform. These will be quick reads that you can consume in a few minutes and will cover a wide range of topics. Today, we are going to look at how the Uno App MCP lets an agent actually run your app and check its own work.

This one is a quick follow-up to my [Agent Skills post]({% post_url 2026-02-23-agent-skills-intro %}). Near the end of that one I added a single line to my prompt, "run the desktop target afterward and confirm the expected behaviour," and the agent just did it: launched the app, clicked a name in a `ListView`, navigated to the next page, and checked the right name came along. That whole step was powered by the App MCP, and it deserves its own tidbit.

## The Problem

Being able to generate correct-looking XAML is great. Making sure it actually works is another matter. Code that builds perfectly can still bind to the wrong property, navigate to the wrong page, or render a button halfway off the screen.

Your agent needs a way to verify that the app behaves as expected at runtime.

Now, given the time, it may very well figure out a way to do it. But wouldn't it be a hell of a lot easier if there were some sort of set of <i>tools</i> that we can provide to agents via some sort of standardized <i>agent protocol</i> that it can call upon whenever it needs?

Something that gives it "eyes" and "hands" to interact with the running app directly?

Something that allows introspection of the app's state in real-time?

Wouldn't that be just so cool??

## The Solution

If you're reading this right now, you should know that I'd be very disappointed in you if you didn't know where this was going already.

Uno actually ships two MCPs, and they're easy to mix up (the team wrote a great [dedicated post][uno-mcp-vs-app-mcp] if you want the deep dive):

- The **Uno MCP** is about *knowledge*. It gives the agent the [Uno docs][uno-docs] as a searchable knowledge base, which shapes what it proposes in the first place.
- The **App MCP** is about *runtime*. It runs locally and reaches into your actual running app. The [docs][uno-mcps-docs] put it perfectly: these tools give "eyes" and "hands" to agents so they can validate the assumptions behind the changes they just made.

## What It Can Do

The App MCP isn't just snapping a screenshot and squinting at it. It's a proper toolbox for driving a live Uno app, and it works!

- `uno_app_get_screenshot`: a screenshot of the app as it looks *right now*
- `uno_app_visualtree_snapshot`: a textual dump of the live visual tree
- `uno_app_pointer_click` and `uno_app_type_text`: click and type into your controls

These ones are pretty obvious things to have, nothing fancy.

Now for the cool shit.

- `uno_app_get_element_datacontext`: retrieves the `DataContext` of a specified `FrameworkElement` in the live visual tree
- `uno_app_element_peer_*`: executes [automation peer][automation-peer-docs] action(s) on a UI element

Giving your agent:

- Access to a textual representation of the `DataContext` on a `FrameworkElement` at runtime.
- Access to a11y APIs to drive app interaction.
- The ability to inspect not only the look but also the state of an element.

That means the agent can confirm your bindings are actually resolving to the values you expect, not just that the XAML parsed.

Fun fact: we actually rely on a lot of these MCP tool calls for our very own [skill plugins][skill-plugins-gh]! You can check out the [uno-testing-assertions][uno-testing-assertions-gh] where we have instructions on how the agent can assert/validate state in 3 different ways:

1. [Visually][skill-visual]
2. [Structurally][skill-struct]
3. [Datally (?)][skill-data]

## Getting Set Up

This is the CLI route. If you would rather set things up in an IDE, the docs have per-environment guides for [Visual Studio][uno-vs-docs], [VS Code with Copilot][uno-vscode-docs], and the rest of the [supported agents][uno-get-started-docs].
{: .notice--info}

Setup is one command. From the root of your app's repo:

```bash
dotnet dnx -y uno.devserver mcp install claude-code
```

That registers both Uno MCPs at once. Start Claude Code and run `/mcp` to confirm you see `UnoApp` and `UnoDocs`.

Two tips that saved me some head-scratching:

1. Run the install from your app's folder, not your home directory, since the registration is scoped to the project.
2. Launch Claude Code from a folder that actually contains your Uno app, otherwise the App MCP has no solution to find and may not load.

Other agents, `--dry-run`, and the full flag list are all in the [docs][uno-mcp-setup-docs].

## Closing the Loop

Put these together and a satisfying loop falls out:

1. The agent uses the **Uno MCP** to research the right approach and proposes a change.
2. That change gets applied and built.
3. The agent launches the app and uses the **App MCP** to check its own work: walk the visual tree, click an element, screenshot the result, and read back the state.

As a quick example, I spun up Claude in my clone of the uno.chefs repo and asked it:

> run the app on desktop, click through the onboarding items on the first page, then login via a social auth button, select a recipe from the home page thats already favourited, unfavourite in its detail page, validate that it shows as unfavourited back on the home page

You can see what happened next:

{% include local-video.html src="/assets/images/app-mcp/chefs-mcp.mp4" %}

<details class="transcript" markdown="1">
<summary>Claude's transcript from that run</summary>

Called UnoApp 7 times
{: .transcript__tool }

The app is running and showing onboarding. Let me get the visual tree to interact properly.

Called UnoApp 3 times
{: .transcript__tool }

Page 2 of 3. Advancing to the third.

Called UnoApp 2 times
{: .transcript__tool }

All three onboarding pages viewed. Now proceeding past onboarding.

Called UnoApp 2 times
{: .transcript__tool }

On the login page. Let me find the social auth buttons.

Called UnoApp 3 times
{: .transcript__tool }

Logged in via Google. On the home page, Fresh Salad Thaid shows a filled (pink) heart — already favourited. Let me open it.

Called UnoApp
{: .transcript__tool }

Let me confirm the favourite state from the data context before navigating.

Called UnoApp
{: .transcript__tool }

Confirmed `IsFavorite = True`. Now opening its detail page.

Called UnoApp 3 times
{: .transcript__tool }

Detail page open — the heart in the top bar is filled. Let me find that toggle.

Called UnoApp 3 times
{: .transcript__tool }

Heart is now unfilled. Navigating back to Home to verify.

Called UnoApp 2 times
{: .transcript__tool }

Back on Home — the heart on Fresh Salad Thaid is now outlined. Confirming in the data:

Called UnoApp 2 times
{: .transcript__tool }

Full flow completed successfully on `net10.0-desktop` (PID 88074).

Steps run:

1. **Onboarding** — clicked through all three welcome pages (Welcome to your App! → Recipes → Personalize Your Recipe Journey; on the third page Next correctly disables), then Skip to reach the login page.
2. **Social auth** — clicked Sign in with Google; landed on the Home page (Trending / Recently Added / Popular Contributors).
3. **Picked an already-favourited recipe** — Fresh Salad Thaid showed a filled pink heart; its DataContext confirmed `IsFavorite = True`.
4. **Unfavourited in detail** — opened the recipe, the nav-bar heart rendered filled, then switched to the outline glyph.
5. **Validated on Home** — navigated back; the Fresh Salad Thaid card's heart is now outlined, and its DataContext reads `IsFavorite = False`.

The propagation works as intended — the detail page's toggle published through `IMessenger` and the home list's `.Observe(...)` state picked it up, so the same recipe record (Id variant 8) reflects the change on both screens.

The app is still running if you want to keep poking at it; `uno_app_close` will shut it down.

</details>

## Conclusion

That's all there is to it!

Pair the App MCP with a solid set of [Agent Skills]({% post_url 2026-02-23-agent-skills-intro %}) and the Uno MCP, and you've got an agent that researches, implements, and verifies. If you build something neat with it, come share it over on the [Uno Discord][uno-discord]!

Catch you in the next one :wave:

[automation-peer-docs]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.automation.peers.automationpeer?view=windows-app-sdk-2.0
[uno-testing-assertions-gh]: https://github.com/unoplatform/studio/blob/main/plugins/uno-platform-studio/skills/uno-testing-assertions/SKILL.md
[skill-plugins-gh]: https://github.com/unoplatform/studio/tree/main/plugins/uno-platform-studio
[skill-visual]: https://github.com/unoplatform/studio/blob/main/plugins/uno-platform-studio/skills/uno-testing-assertions/SKILL.md#visual-assertions-screenshots
[skill-struct]: https://github.com/unoplatform/studio/blob/main/plugins/uno-platform-studio/skills/uno-testing-assertions/SKILL.md#structure-assertions-visual-tree
[skill-data]: https://github.com/unoplatform/studio/blob/main/plugins/uno-platform-studio/skills/uno-testing-assertions/SKILL.md#data-assertions

{% include links.md %}
