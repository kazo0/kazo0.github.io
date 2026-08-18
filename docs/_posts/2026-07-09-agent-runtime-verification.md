---
title: "Teaching Your Agent to See: Runtime Verification with the Uno App MCP"
category: uno-general
header:
  teaser: /assets/images/agent-runtime-verification/hero.png
  og_image: /assets/images/agent-runtime-verification/hero.png
tags: [agents, ai, mcp, app-mcp, runtime, verification, uno-platform, uno, unoplatform]
---

In my [last post]({% post_url 2026-02-23-agent-skills-intro %}), we dug into Agent Skills and how they guide an agent toward the right Uno MCP tools for a given task. There was one moment near the end that I kind of rushed past, but honestly it's the part that stuck with me the most. I added a single line to my prompt:

> Run the desktop target afterward and confirm the expected behaviour

And the agent just... did it. It launched the app, clicked a name in a `ListView`, navigated to the next page, and checked that the right name had come along for the ride. No hand-holding from me. That whole "go run it and make sure it actually works" step was powered by the Uno App MCP, and I think it's worth slowing down and giving it the attention it deserves.

## The Problem

Here's something every AI coding assistant loves to tell you: "The code compiles!" Great. But if you've been writing software for more than about a week, you know that compiling and working are two very different things.

Code that builds perfectly can still bind to the wrong property, navigate to the wrong page, or render a button halfway off the screen. When an agent can only read your source, it's essentially reasoning in the dark. It writes some XAML, sees a green build, and declares victory. Then you hit F5 and the `ListView` is empty.

The agent has no eyes and no hands. It can't run the app, look at it, or poke at it the way you and I do a hundred times a day. So it guesses. And when I'm handing off work to an agent, "it should probably work" isn't the confidence level I'm after.

## The Two MCPs

Before we get into the fun part, a quick refresher, because the Uno MCP and the App MCP are easy to mix up. If you want the deep dive, the team wrote a great [dedicated post][uno-mcp-vs-app-mcp] on exactly this.

1. The **Uno MCP** is about *knowledge*. It gives the agent the entire [Uno documentation][uno-docs] as a searchable knowledge base through tools like `uno_platform_docs_search`. This is what shapes what the agent proposes in the first place.
2. The **App MCP** is about *runtime*. It runs locally and lets the agent reach into your actual running app. The [docs][uno-mcps-docs] describe it perfectly: these tools give "eyes" and "hands" to agents so they can validate the assumptions behind the changes they just made.

I used a cooking analogy last time, so let me keep it going: if the Uno MCP is the pantry of ingredients and Agent Skills are the recipes, then the App MCP is the agent finally walking over to the stove, tasting the dish, and fixing the seasoning before it ever reaches your plate.

## What the App MCP Can Actually Do

This is where it clicked for me. The App MCP isn't just snapping a screenshot and squinting at it. It's a proper toolbox for driving a live Uno app, and it works across Windows, WebAssembly, macOS, iOS, Android, and Linux.

Here's what ships under the Community license:

- `uno_app_get_runtime_info`: general info about the running app (PID, OS, platform, and so on)
- `uno_app_get_screenshot`: a screenshot of the app as it looks *right now*
- `uno_app_pointer_click`: click at an X,Y coordinate
- `uno_app_key_press`: press individual keys, optionally with modifiers
- `uno_app_type_text`: type longer strings into a control
- `uno_app_visualtree_snapshot`: a textual dump of the live visual tree
- `uno_app_element_peer_default_action`: run the default automation peer action on an element
- `uno_app_close`: close the running app

And a couple more come with the Pro license:

- `uno_app_element_peer_action`: invoke a *specific* automation peer action
- `uno_app_get_element_datacontext`: read a textual representation of the `DataContext` on a `FrameworkElement`

That last one is the one I keep thinking about. Being able to read an element's `DataContext` means the agent can confirm your bindings are actually resolving to the values you expect, not just that the XAML parsed cleanly. Anyone who's lost an afternoon to a silent binding failure knows exactly why that's a big deal.

## Closing the Loop

Put these together and a really satisfying loop falls out of it:

1. The agent leans on the **Uno MCP** to research the right approach and proposes a change.
2. That change gets applied and built.
3. The agent launches the app and uses the **App MCP** to check its own work: walk the visual tree to confirm an element is there, click it, type into it, screenshot the result, and read back the state.

The key shift is that the agent stops reasoning about static code in a vacuum. It's checking against the *running application* now, which is exactly what you do when you hit F5 and start clicking around.

Back to that MVUX selection example from last time: once the agent wired up the `ListView` and the model, it didn't just trust the build. It grabbed a visual tree snapshot to make sure the list was actually populated, clicked an item, navigated to the second page, and screenshotted it to confirm the selected name made the trip. And that's the real payoff, because when something *is* off, that same loop is what lets the agent notice and fix it instead of handing me code that only looks finished.

## Getting Set Up

The good news: there isn't much ceremony here. The App MCP is part of the Uno tooling, and if you've been following the recommended agentic setup, you might already have it wired up. Since it's a local runtime service, the one thing to remember is that your app has to actually be running for the agent to attach to it.

A few notes from my own tinkering:

- The App MCP is **local**. It talks to a running instance of your app on your machine, not some hosted service.
- It spans all of Uno's targets, so you can point it at your desktop target for quick iteration and trust that the behavior carries over to the rest.
- If you're in Visual Studio and the App MCP indicator goes red, don't panic like I did. The fix is usually just to reload it: click the three dots and hit **Reload**. I spent way too long on that before spotting the note in the [docs][common-issues-ai-agents].

For the full reference, the [Uno MCPs documentation][uno-mcps-docs] and the [Explore Your App with AI Agents][explore-app-ai] guide both go deeper than I can fit here.

## Conclusion

The more I use it, the more I'm convinced that the real value of an agent isn't how fast it writes code, it's how well it can check its own work. A tight feedback loop is what separates an agent that produces plausible-looking code from one that produces code that actually runs the way you asked.

Giving your agent eyes and hands through the App MCP is a genuine step in that direction. It's the difference between "I wrote the XAML you asked for" and "I wrote it, ran it, clicked the button, and confirmed the right page showed up." I know which of those two I'd rather have on my team.

Pair the App MCP with a solid set of [Agent Skills]({% post_url 2026-02-23-agent-skills-intro %}) and the Uno MCP, and you've got an agent that researches, implements, and verifies. I'd love to hear how others are folding runtime verification into their own workflows, so if you've built something neat with the App MCP, come share it over on the [Uno Discord][uno-discord]!

Catch you in the next one :wave:

{% include links.md %}
