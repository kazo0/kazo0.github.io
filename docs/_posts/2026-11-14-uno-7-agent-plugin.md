---
title: "Uno Platform 7.0 and the uno-dev Agent Plugin"
category: uno-general
header:
  teaser: /assets/images/uno-7-agent-plugin/hero.png
  og_image: /assets/images/uno-7-agent-plugin/hero.png
tags: [agents, ai, skills, plugin, claude-code, copilot, codex, uno-platform, uno, unoplatform]
---

Uno Platform 7.0 is out, and it's a big one. The [release blog][uno-7-blog] has the headline numbers (about 2x faster and 5x smaller than 6.7), plus a pile of platform and rendering work that deserves its own posts.

This one is about a less flashy thing that landed the same week: the Uno Platform Studio agent plugin got its [7.0.0 release][studio-release]. If you read my [Agent Skills post]({% post_url 2026-02-23-agent-skills-intro %}), I wrote a single skill by hand to teach an agent about MVUX selection. The plugin is that same idea at a much bigger scale, and I've been neck deep in that repo for a while now.

Let's walk through what's in it, how to install it, and what it will and won't do for you.

<!-- TODO: hero image for the post (hero.png). Something agent-flavored with the Uno logo, a terminal with the uno-dev agent selected would work. -->

## What's in the Plugin

The plugin is called `uno-platform-studio` and it has three parts:

- **The `uno-dev` agent.** Describe what you want in plain language: a new app from a brief, a feature for an existing app, or a binding, state, or navigation bug. It plans the work, builds and runs the first feature before repeating the pattern, and finishes with a report.
- **Nine skills.** A workflow skill (`uno-build-app`), a router (`uno-platform`), and seven domain skills: `uno-mvux`, `uno-navigation`, `uno-toolkit`, `uno-themes`, `uno-authentication`, `uno-kiota`, and `uno-testing`.
- **Claude Code hooks.** While your app is running, they keep the agent on Hot Reload instead of rebuilding after every edit.

It installs in Claude Code, GitHub Copilot CLI, GitHub Copilot in VS Code, and OpenAI Codex CLI. Agents without plugin support (Cursor, Gemini CLI, Windsurf, Cline, and others) can copy the same skills from the repo's `skills/` folder.

## Why Nine Skills Instead of Sixty-Two

The first releases of this plugin shipped one skill per topic. Sixty-two of them. That looked tidy on paper, and then I measured it.

An agent picks a skill from its name and description alone, and every host caps how much room that listing gets. Claude Code budgets roughly 1% of the context window for it and drops the descriptions once it goes over. My 62 skills added up to about 27,000 characters of listing text. In a live session with other plugins installed, 56 of the 62 Uno skills reached the model as bare names with no description. So they never triggered on natural phrasing.

Sound familiar? It's the same problem from my Agent Skills post, just one level up. A skill the agent doesn't pick might as well not exist.

The fix was to fold the 62 into six domain hubs. Each hub has a keyword-rich description, a topic map, and the critical rules. The old per-topic skills didn't go anywhere. Each one became a short reference file inside its hub, and the agent reads it only when the task calls for it. With the six hubs the listing dropped from about 27,000 to about 5,300 characters. The numbers are in the [PR description][studio-pr-157] if you want the details.

The plugin has grown to nine skills since then, with the build workflow, authentication, and Kiota added. There are 94 reference files across them today, and `uno-toolkit` alone has 32.

## Installing It

Installing takes a few commands. Pick your agent:

```text
# Claude Code
/plugin marketplace add unoplatform/studio
/plugin install uno-platform-studio@uno-platform

# GitHub Copilot CLI
copilot plugin marketplace add unoplatform/studio
copilot plugin install uno-platform-studio@uno-platform

# OpenAI Codex CLI
codex plugin marketplace add unoplatform/studio
codex plugin add uno-platform-studio@uno-platform
```

For Copilot in VS Code, add `unoplatform/studio` to the `chat.plugins.marketplaces` setting and install `uno-platform-studio` from the agent-plugins picker. In Claude Code, run `/reload-plugins` if it asks, then `/skills` to check that they showed up.

<!-- TODO: screenshot of the /skills list in Claude Code after installing, showing the uno-* skills (installed-skills.png). -->

The plugin doesn't bundle the two MCP servers it leans on, the Uno docs MCP and the Uno App MCP. They come with the Uno tooling. If you need a refresher on the difference between them, I'd start with the [Uno MCP vs App MCP blog post][uno-mcp-vs-app-mcp] and the [setup docs][uno-mcp-setup-docs].

## Meet uno-dev

Don't start with the skills. Start with the agent:

```text
# Claude Code
claude --agent uno-platform-studio:uno-dev

# GitHub Copilot CLI
copilot --agent uno-dev
```

Then tell it what you want. The README's example is "Build me a reading tracker with a yearly goal setting."

Codex plugins can't bundle agents yet ([openai/codex#18988][codex-18988]), so there you copy `codex/uno-dev.toml` into `.codex/agents/` yourself. A small chore, but worth knowing about.

The agent itself is thin. It loads the `uno-build-app` skill, which owns the process: discover, define a contract for the feature, implement one complete feature, build it, start it, exercise it, and only then repeat the pattern. The skill has a list of rules that do not bend, and these are the ones I'd call out:

1. Read the project first. Existing apps keep their architecture, navigation, and theme, so an MVVM app stays MVVM.
2. Exercise the first feature in the running app before copying its pattern.
3. Never claim a check you didn't run.
4. Every control gets an automation id, written with the element and not as a later pass.

That last one looks like this:

```xml
<Button AutomationProperties.AutomationId="SaveButton"
        Content="Save"
        Command="{Binding Save}" />
```

The testing skill drives the app by `automationId` in a single call, with no visual tree snapshot first. A control without one costs the agent a snapshot or a coordinate click every single time.

Then there's the one that keeps Studio's own UI out of your screenshots. In an app the agent creates, it adds this to `App.xaml.cs`:

```csharp
#if DEBUG
MainWindow.UseStudio(showHotReloadIndicator: false, launchHotDesignOnStart: false);
#endif
```

Otherwise the Hot Reload indicator and the Hot Design button sit on top of the app in every Debug screenshot and under every pointer click. In an existing app it asks you first.

<!-- TODO: screenshot of a uno-dev session in the terminal mid-run, ideally the point where it exercises the app through the App MCP (uno-dev-session.png). -->

The end of every run is a report that separates what ran, what failed, and what couldn't run. The closing line is one of three fixed sentences, so the agent can't say "done" when a required check never happened. In my reading tracker test runs it was "Implementation complete; verification incomplete.", followed by the list of checks that hadn't run.

<!-- TODO: screenshot of a completion report with the closing line visible (completion-report.png). -->

## Is It Worth the Extra Time?

I compared the hubs alone against the hubs driven by `uno-dev` on that reading tracker prompt, three runs each. Both built an app every time. The difference was what happened afterward.

The `uno-dev` runs wrote tests (31, 32, and 24 of them), made 14 to 26 App MCP calls instead of 5 to 6, and found real bugs by actually using the app. A yearly goal that never persisted. Escape deleting a book. A Remove button that did nothing. Then they fixed them.

It isn't free, though. The median `uno-dev` run cost about $7.30 and took 15.6 minutes, against $2.60 and 5.8 minutes for the hubs alone. Three runs a side shows the direction, not a precise size, so treat those as ballparks. The [PR description][studio-pr-148] has the full table.

## Stop Rebuilding the App

If you've watched an agent work on a UI, you've seen the loop: edit XAML, rebuild, relaunch, navigate back to where you were, check, repeat. Every one of those restarts costs real time, and Hot Reload is sitting right there.

The Claude Code hooks push the agent toward it. There are two:

- **`SessionStart`.** In an Uno project, it reminds the agent that a running app is edited through Hot Reload and not rebuilt, and to look for a running app before the first build. In any other folder it prints nothing.
- **`PostToolUse`.** After the agent edits a `.xaml` or `.cs` file, it asks the DevServer whether the running app picked up the edit and passes the answer along.

That second hook runs a command from the new `uno-devserver app` family that the 7.0 release blog mentions for driving running apps from scripts, CI, and agents. The [docs][devserver-app-docs] even use it as their example for a hook:

```bash
uno-devserver app hot-reload-status --file src/MyApp/MainPage.xaml --waitForMs 10000 --no-start
```

The exit code tells the story. Zero means there's nothing left to do, usually because the edit applied. One means it isn't running in the app, and the output says why. Three means a rude edit, and only a restart will pick it up. Four means it's still on its way. So the agent asserts on the change, fixes the compile errors the status reports, or restarts only when it actually has to.

The hook also says nothing before the app exists. Reminding the agent on every scaffolding edit just taught it to skim the reminders. I covered what the App MCP can do once the app is up in [the App MCP tidbit]({% post_url 2026-08-19-tidbit-app-mcp %}).

<!-- TODO (optional): short screen recording of an edit applying through Hot Reload while the agent works, with the hook output visible (hot-reload-hook.mp4). Embed it as an MP4 with the local-video include. -->

## What to Know Before You Try It

A few honest caveats:

- **The hooks are Claude Code only.** Copilot and Codex don't load them, so there the same rule rides along as text in the skills.
- **App MCP tools depend on your license.** A Community license lacks `uno_app_element_peer_action` and `uno_app_get_element_datacontext`, which are Pro or Business. The testing skill has fallbacks (pointer clicks instead of peer actions) and reports DataContext assertions as not run.
- **Release builds can't be driven by the App MCP.** The testing skill verifies them through the platform accessibility tree on Windows and Android. Everywhere else it falls back to a static review and labels it unverified.
- **The version tracks the SDK.** Plugin 7.0.x targets Uno.Sdk 7.0. Marketplace installs use the release tag, and `main` can describe things that only exist in the next SDK.

## Conclusion

The skills got the agent to look in the right place. The plugin wraps a process around them: a workflow, a way to check the work against the running app, and a report that has to admit what it couldn't verify. It's still young, so if a skill gives you wrong or missing guidance, please [open an issue][studio-issues].

Try it on a small app first and let me know what it gets wrong.

Catch you in the next one :wave:

[uno-7-blog]: https://platform.uno/blog/uno-platform-7-0/
[studio-release]: https://github.com/unoplatform/studio/releases/tag/7.0.0
[studio-pr-157]: https://github.com/unoplatform/studio/pull/157
[studio-pr-148]: https://github.com/unoplatform/studio/pull/148
[studio-issues]: https://github.com/unoplatform/studio/issues/new/choose
[codex-18988]: https://github.com/openai/codex/issues/18988
[devserver-app-docs]: https://platform.uno/docs/articles/features/devserver-app-commands.html

{% include links.md %}
