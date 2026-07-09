---
title: "Teaching Your Agent to See: Runtime Verification with the Uno App MCP"
category: uno-general
header:
  teaser: /assets/images/agent-runtime-verification/hero.png
  og_image: /assets/images/agent-runtime-verification/hero.png
tags: [Agents, AI, MCP, app-mcp, runtime, verification, uno-platform, uno, unoplatform]
---

Uno Platform has been on a tear with AI-assisted development lately, and I've been having a lot of fun poking at the edges of what's possible. In my [last post on Agent Skills]({% post_url 2026-02-23-agent-skills-intro %}), there was a moment near the end that I kind of glossed over, but it's honestly the part that impressed me the most. I added a small instruction to my prompt:

> Run the desktop target afterward and confirm the expected behaviour

And the agent did exactly that. It started up the app, selected a name from a `ListView`, and verified that the correct name showed up on the next page. Entirely on its own. That last bit was powered by the Uno **App MCP**, and I think it deserves its own post. So today, let's talk about how you can teach your agent to actually *see* what it's building.

## The Problem: "It Compiles" Is Not "It Works"

Most AI coding assistants stop at the same place: the code compiles, so the job must be done. Any developer who has shipped software knows how big of a leap that is. Code that builds can still bind to the wrong property, navigate to the wrong page, throw at runtime, or render a button three pixels off the edge of the screen.

When an agent can only read your source code, it's essentially guessing at runtime behavior. It has no eyes and no hands. It writes some XAML, sees a successful build, and confidently declares victory. Then you run the app and the `ListView` is empty.

This is the gap the App MCP fills.

## Uno MCP vs App MCP

Quick refresher, because these two are easy to mix up (the team has a great [dedicated blog post][uno-mcp-vs-app-mcp] if you want the full breakdown):

1. The **Uno MCP** is the *knowledge* tool. It gives the agent access to the entire [Uno documentation][uno-docs] as a searchable knowledge base via tools like `uno_platform_docs_search`. This is what informs the agent's proposals.
2. The **App MCP** is the *runtime* tool. It runs locally and lets the agent interact with your actual running app. As the [docs][uno-mcps-docs] put it, these tools give "eyes" and "hands" to agents so they can validate their assumptions about the changes they've made.

If Agent Skills are the recipes and the Uno MCP is the pantry of ingredients, then the App MCP is the agent stepping up to the stove, tasting the dish, and adjusting the seasoning before serving it to you.

## What the App MCP Can Actually Do

This is the part that made me sit up. The App MCP isn't just taking a screenshot and hoping for the best. It exposes a whole toolbox for interacting with a live Uno app across Windows, WebAssembly, macOS, iOS, Android, and Linux.

Here are the tools available under the Community license:

- `uno_app_get_runtime_info` — general info about the running app (PID, OS, platform, etc.)
- `uno_app_get_screenshot` — a screenshot of the app as it looks *right now*
- `uno_app_pointer_click` — click at an X,Y coordinate
- `uno_app_key_press` — press individual keys, optionally with modifiers
- `uno_app_type_text` — type longer strings into controls
- `uno_app_visualtree_snapshot` — a textual dump of the app's live visual tree
- `uno_app_element_peer_default_action` — invoke the default automation peer action on an element
- `uno_app_close` — close the running app

And a couple more under the Pro license that are worth calling out:

- `uno_app_element_peer_action` — invoke a *specific* automation peer action
- `uno_app_get_element_datacontext` — get a textual representation of the `DataContext` on a `FrameworkElement`

That last one is spicy. Reading the `DataContext` of an element means the agent can verify that your bindings are actually resolving to the values you expect, not just that the XAML parsed. For anyone who has spent an afternoon hunting a silent binding failure, you know how valuable that is.

## The Verification Loop

Once you put these together, a really nice loop emerges. It roughly goes:

1. The agent uses the **Uno MCP** to research the right approach and proposes a change.
2. You (or the agent) apply and build it.
3. The agent launches the app and uses the **App MCP** to verify the result — walking the visual tree to confirm an element exists, clicking it, typing into it, screenshotting the output, and reading back the resulting state.

The important shift here is that the agent is no longer reasoning about static code in a vacuum. It's closing the loop against the *running application*, which is exactly what a human developer does when they hit F5 and start clicking around.

Circling back to my MVUX selection example from last time: after wiring up the `ListView` and the MVUX model, the agent didn't just trust that it compiled. It grabbed a visual tree snapshot to confirm the `ListView` was populated, clicked an item, navigated to the second page, and screenshotted it to confirm the selected name came through. When something is off, that same loop is what lets it notice and iterate rather than handing you broken code.

<!-- TODO: screenshot of the agent calling uno_app_visualtree_snapshot / uno_app_get_screenshot during a run (e.g. Claude Code tool-call panel) -->

## Setting It Up

The good news is that there isn't much ceremony here. The App MCP ships as part of the Uno tooling, and if you've been following along with the recommended agentic setup, you may already have it configured. The App MCP is a local runtime service, so it needs your app to actually be running for the agent to attach to it.

A few things worth keeping in mind:

- The App MCP is **local** — it talks to a running instance of your app on your machine, not a hosted service.
- It works across all of Uno's target platforms, so you can point it at your desktop target for fast iteration and trust that the same behavior carries elsewhere.
- If you're in Visual Studio and the App MCP indicator turns red, the fix is usually just to reload it (click the three dots and select **Reload**). I ran into this myself and spent longer than I'd like to admit before finding that note in the [docs][common-issues-ai-agents].

If you want the deeper reference, the [Uno MCPs documentation][uno-mcps-docs] and the [Explore Your App with AI Agents][explore-app-ai] guide both go into more detail than I can fit here.

## Why This Matters

I keep coming back to the same thought: the value of an agent isn't just in how fast it writes code, it's in how well it can *check its own work*. A tight feedback loop is what separates an agent that produces plausible-looking code from one that produces code that actually runs the way you asked.

Giving your agent eyes and hands via the App MCP is a genuine step toward that. It's the difference between "I wrote the XAML you asked for" and "I wrote it, ran it, clicked the button, and confirmed the right page showed up." The second one is the developer I want on my team, human or otherwise.

## Conclusion

The App MCP is one of those tools that sounds like a nice-to-have until you watch it work, and then you can't imagine going back. Pair it with a solid set of [Agent Skills]({% post_url 2026-02-23-agent-skills-intro %}) and the Uno MCP, and you've got an agent that researches the right approach, implements it, and verifies it against a running app.

I'd love to see how others are wiring runtime verification into their workflows. If you've built something cool with the App MCP, come share it in the [Uno Discord][uno-discord]!

Catch you in the next one :wave:

{% include links.md %}
