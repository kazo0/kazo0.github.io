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

Every AI coding assistant loves to tell you "the code compiles!" Great. But you and I both know compiling and working are two very different things. Code that builds perfectly can still bind to the wrong property, navigate to the wrong page, or render a button halfway off the screen.

When an agent can only read your source, it's reasoning in the dark. It writes some XAML, sees a green build, and declares victory. Then you hit F5 and the `ListView` is empty. The agent has no eyes and no hands, so it guesses, and "it should probably work" isn't the confidence level I'm after.

## The Solution

Uno actually ships two MCPs, and they're easy to mix up (the team wrote a great [dedicated post][uno-mcp-vs-app-mcp] if you want the deep dive):

- The **Uno MCP** is about KNOWLEDGE. It gives the agent the [Uno docs][uno-docs] as a searchable knowledge base, which shapes what it proposes in the first place.
- The **App MCP** is about RUNTIME. It runs locally and reaches into your actual running app. The [docs][uno-mcps-docs] put it perfectly: these tools give "eyes" and "hands" to agents so they can validate the assumptions behind the changes they just made.

## What It Can Do

The App MCP isn't just snapping a screenshot and squinting at it. It's a proper toolbox for driving a live Uno app, and it works across Windows, WebAssembly, macOS, iOS, Android, and Linux. A few of my favorites from the Community license:

- `uno_app_get_screenshot`: a screenshot of the app as it looks RIGHT NOW
- `uno_app_visualtree_snapshot`: a textual dump of the live visual tree
- `uno_app_pointer_click` and `uno_app_type_text`: click and type into your controls

And one Pro tool I keep thinking about, `uno_app_get_element_datacontext`, reads a textual representation of the `DataContext` on a `FrameworkElement`. That means the agent can confirm your bindings are actually resolving to the values you expect, not just that the XAML parsed. Anyone who's lost an afternoon to a silent binding failure knows why that's a big deal.

## Closing the Loop

Put these together and a satisfying loop falls out:

1. The agent uses the **Uno MCP** to research the right approach and proposes a change.
2. That change gets applied and built.
3. The agent launches the app and uses the **App MCP** to check its own work: walk the visual tree, click an element, screenshot the result, and read back the state.

The key shift is that the agent stops reasoning about static code in a vacuum and starts checking against the RUNNING app, which is exactly what you do when you hit F5 and start clicking around. Back to that selection example: once the agent wired up the `ListView`, it grabbed a visual tree snapshot to confirm the list was populated, clicked an item, navigated to the second page, and screenshotted it to make sure the selected name made the trip.

One small gotcha to save you the headache I gave myself: the App MCP is a local runtime service, so your app has to actually be running for the agent to attach. And if the App MCP indicator goes red in Visual Studio, don't panic like I did, just click the three dots and hit Reload. It's in the [docs][common-issues-ai-agents], which I found only after spending way too long on it.

## Conclusion

The more I use it, the more I'm convinced the real value of an agent isn't how fast it writes code, it's how well it can check its own work. Pair the App MCP with a solid set of [Agent Skills]({% post_url 2026-02-23-agent-skills-intro %}) and the Uno MCP, and you've got an agent that researches, implements, and verifies. If you build something neat with it, come share it over on the [Uno Discord][uno-discord]!

Catch you in the next one :wave:

{% include links.md %}
