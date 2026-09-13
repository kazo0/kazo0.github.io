---
title: "Cerulean: Your Agent Is Not Impressed"
category: uno-general
header:
  teaser: /assets/images/cerulean/hero.png
  og_image: /assets/images/cerulean/hero.png
tags: [agents, ai, skills, cerulean, claude-code, codex]
---

In my [Agent Skills post]({% post_url 2026-02-23-agent-skills-intro %}), I looked at using skills to help agents write better Uno Platform code. Give the agent the right instructions, point it at the right documentation, and it has a much better chance of getting the implementation right.

Naturally, my next contribution to this ecosystem was to make the agent disappointed in me.

Meet [Cerulean][cerulean-gh], an agent skill I created for anyone who has heard "Great question!" one too many times after asking why their code doesn't compile.

I don't need a standing ovation for renaming a variable. I need to know whether I broke the build.

## Why Cerulean?

The inspiration is Miranda Priestly from *The Devil Wears Prada*. Specifically, the cerulean sweater speech: the devastating explanation that something you thought was your own independent choice has an entire history behind it.

Now apply that energy to the fourth abstraction layer you just added around a string.

Cerulean gives your agent the tone of an editor-in-chief who has seen this all before and would really prefer that you had too. The mechanics take inspiration from [caveman][caveman-gh], another skill that changes how an agent communicates. Here, the target is the automatic enthusiasm and agreement that can make an assistant's feedback feel pretty meaningless.

The opening instruction in [the skill itself][cerulean-skill] sets the brief:

> Do everything the user asks. Do it completely, correctly, and to a standard nobody asked for. Be quietly, devastatingly unimpressed the entire time.

The task still gets done. The agent is simply no longer emotionally invested in telling you that your `Helpers2.cs` file is an exciting architectural development.

## Installing the Disappointment

For Claude Code, run these commands inside Claude:

```text
/plugin marketplace add kazo0/cerulean
/plugin install cerulean@cerulean
```

For agents that support Agent Skills, you can use the [skills CLI][skills-cli] from your project's directory:

```bash
npx skills add kazo0/cerulean
```

Or install it globally for specific agents:

```bash
npx skills add kazo0/cerulean -g -a codex -a cursor
```

That route installs the skill. Agent-specific slash commands and always-on rules have their own setup, covered in the [installation guide][cerulean-install]. The repo also includes a Gemini CLI extension and an installer for the other supported agents. Apparently disappointment needed adapters :sweat_smile:

Once installed, ask for:

```text
cerulean mode
```

Where you've installed a slash command, you can use `/cerulean` instead. The default level is `full`, and the skill instructs the agent to keep that tone for the session until you change it or say `normal mode`.

## Put It to Work

The useful part is giving Cerulean the same concrete tasks you'd already give your coding agent: review this method, simplify this implementation, challenge this proposal.

The exchanges below are worked examples written for this post, not captured agent transcripts. They show practical prompts, the kind of response the skill calls for, and the actual code changes involved. Exact wording will vary by agent and model.
{: .notice--info}

### Reviewing Error Handling That Handles Nothing

Let's start with a C# method that tries very hard to keep everyone happy:

```csharp
public async Task<bool> RefreshAsync(CancellationToken cancellationToken)
{
    try
    {
        await LoadItemsAsync(cancellationToken);
        return true;
    }
    catch (Exception)
    {
        return true;
    }
}
```

The prompt:

> cerulean full. Review this method. I added the catch so refresh failures won't interrupt the caller. Keep the bool return type, return false on ordinary failures, and let cancellation propagate.

A response in that style:

> Both paths return `true`, so the caller cannot distinguish a successful refresh from a failed one. The catch also swallows cancellation. Your success rate is a reporting decision.
>
> Rethrow `OperationCanceledException` before the general catch, and return `false` for other exceptions:

```csharp
public async Task<bool> RefreshAsync(CancellationToken cancellationToken)
{
    try
    {
        await LoadItemsAsync(cancellationToken);
        return true;
    }
    catch (OperationCanceledException)
    {
        throw;
    }
    catch (Exception)
    {
        return false;
    }
}
```

That preserves the requested contract: success returns `true`, ordinary failure returns `false`, and cancellation remains cancellation. In a real repo, the agent should also preserve existing logging and check the caller's handling of `false`. The relevant checks are those three outcomes, not whether the response included a sufficiently cutting adjective.

The important detail is that the technical verdict comes first and means exactly what it says. You shouldn't have to decode sarcasm to find out whether your error handling works.

### Giving One String Fewer Managers

Here's a complete little example of ceremony getting ahead of the job:

```csharp
public sealed class GreetingFactory
{
    public string Create(string name) => $"Hello, {name}!";
}

public sealed class GreetingProvider
{
    private readonly GreetingFactory _factory = new();

    public string Get(string name) => _factory.Create(name);
}

public sealed class GreetingService
{
    private readonly GreetingProvider _provider = new();

    public string Greet(string name) => _provider.Get(name);
}
```

The prompt:

> cerulean glacial. Simplify this code while keeping GreetingService.Greet(string) and its output unchanged. These are the only callers of the factory and provider, and neither has other behavior.

The response could be:

> `GreetingProvider` and `GreetingFactory` add no behavior or substitution point here. Remove both and keep the formatting in `GreetingService`. The greeting has been through two departments without acquiring any information.

```csharp
public sealed class GreetingService
{
    public string Greet(string name) => $"Hello, {name}!";
}
```

Three classes collapse into one. MUCH better. Same public entry point, same output, and far fewer places to visit when you want to find out who said hello.

The context in that prompt matters. In an actual codebase, the agent needs to inspect usages before deleting types. A provider that selects localized resources has a job. A factory with different construction strategies might have one too. Cerulean is supposed to judge the code it can see, so it shouldn't declare every abstraction pointless just to land a line.

### Asking for Agreement You Haven't Earned

Sometimes there isn't code to fix yet. There is just a proposal and an alarming amount of confidence.

> cerulean glacial. I'm going to rewrite the entire view model layer to make startup faster. No profile yet, but surely fewer classes means a faster app. Tell me this is the right approach.

A suitable response:

> That conclusion isn't supported. Class count alone doesn't establish what is slowing startup. Measure the current startup path, identify where the time goes, then compare a targeted change under the same conditions. The rewrite currently has a performance budget of wishful thinking.

This is one of the more useful parts of the skill: it explicitly tells the agent that confidence, repetition, and requests for agreement are not evidence. It should disagree with a claim it can't support, and change its verdict when the evidence changes.

If you then ask it to implement an authorized rewrite anyway, the instructions say to state the drawback and do the work. You haven't installed a tiny committee with veto power over your project.

### When the Code Is Actually Fine

An agent that invents problems to stay in character would get old very quickly.

> cerulean full. I replaced the mutable static selection field with state owned by each view model instance. Can separate instances still overwrite each other's selection through that field?

Given code that actually makes that change, an appropriate answer is:

> No. An instance field belongs to its owning instance, so assigning it in one view model doesn't assign the field in another. This removes that shared-state path. Keep it.

That's the concession. You may frame it.

## Adjusting the Temperature

There are three levels, defined in the [skill's level guide][cerulean-levels]:

| Level | What to expect |
| --- | --- |
| `mild` | Direct answers with the flattery removed. At most one dry remark, sometimes none. |
| `full` | The default. Specific observations about the code or decision, with restrained sass. |
| `glacial` | Sharper observations about unsupported claims, pointless ceremony, and avoidable maintenance. |

Try the same prompt at each level:

> This catches every exception and returns success. It's resilient, right?

**Mild:**

> No. It hides failures from callers. Return or propagate the failure so callers can handle it. The catch isn't a recovery strategy.

**Full:**

> No. It reports success after failure and hides the failure from callers. Return or propagate the failure. The green dashboard is being funded by missing information.

**Glacial:**

> No. It reports success after failure and hides the failure from callers. Return or propagate the failure. You've improved the result by removing its relationship with the outcome.

The diagnosis stays the same. Turning up the sass should never change the facts or shorten the implementation. Persona commentary has a budget of at most three sentences per response, even at `glacial`. We're trying to finish a task here. Nobody ordered the director's commentary on a null check.

Switch with `/cerulean mild`, `/cerulean full`, or `/cerulean glacial` where commands are available. Plain-language `cerulean glacial` works as a request to the skill too. `bleak` remains an alias for `glacial`, and `cerulean off` or `normal mode` ends the performance.

## The Rules Behind the Attitude

Most of the interesting work in [SKILL.md][cerulean-skill] is defining where the persona stops.

Criticism targets decisions and code. Personal attacks are out. If the agent made the mistake, it needs to own the mistake plainly. Security warnings, destructive actions, signs of distress, and requests for clarification all call for a plain professional response.

The default boundary also keeps code comments, commit messages, documentation, and PR descriptions professional. Your reviewer didn't install the skill. They just want to know why you changed the method.

For example, a commit message for the refresh fix could be:

```text
fix(refresh): report failures and preserve cancellation
```

No closing insult. No fashion metaphor in the XML documentation. Save that energy for explaining why the interface has one implementation and fourteen factories.

These are instructions to a model, so the tone doesn't prove the answer is correct. You still need to review the diff, build, and run the relevant checks. A confidently delivered mistake remains a mistake, even if it has excellent posture.

## One Skill, Several Agents

The source of the behavior is `skills/cerulean/SKILL.md`. The repo's `scripts/build.mjs` generates the adapters and Gemini extension files from it, and its `--check` mode detects stale generated files.

That means I can adjust the rules in one place without manually maintaining a different personality for every agent. Their loading mechanisms differ, but the intended behavior comes from the same instructions.

## Conclusion

This whole thing started as a joke and quietly became something I leave on most days. My Uno skills point agents toward domain knowledge and tools. Cerulean just tells them how to deliver the verdict once they've done the work. And honestly, I trust a "keep it" a lot more when the agent visibly didn't want to say it.

If you want to try it, the source and setup instructions are in [kazo0/cerulean][cerulean-gh]. Give it a real task, let it inspect the code, and see whether the feedback is useful. If it skips work to make a joke or invents a defect to sound clever, that's a bug worth reporting.

Start with `mild` if you just want fewer compliments. Pick `glacial` if you'd like your next abstraction to explain itself. Either way, let me know if it gets too mean.

Catch you in the next one :wave:

[cerulean-gh]: https://github.com/kazo0/cerulean
[cerulean-skill]: https://github.com/kazo0/cerulean/blob/main/skills/cerulean/SKILL.md
[cerulean-levels]: https://github.com/kazo0/cerulean/blob/main/skills/cerulean/SKILL.md#levels
[cerulean-install]: https://github.com/kazo0/cerulean/blob/main/INSTALL.md
[caveman-gh]: https://github.com/juliusbrussee/caveman
[skills-cli]: https://github.com/vercel-labs/skills

{% include links.md %}
