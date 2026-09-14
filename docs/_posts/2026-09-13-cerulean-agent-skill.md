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

Cerulean now has one style: **Glacial**. Turn it on and you get direct technical verdicts, pointed observations about the code, and very little interest in congratulating you for opening the editor. There is no temperature selector. The work still has to be complete and correct.

## Why Cerulean?

The inspiration is Miranda Priestly from *The Devil Wears Prada*. Specifically, the cerulean sweater speech: the devastating explanation that something you thought was your own independent choice has an entire history behind it.

Now apply that energy to the fourth abstraction layer you just added around a string.

Cerulean gives your agent the tone of an editor-in-chief who has seen this all before and would really prefer that you had too. The mechanics take inspiration from [caveman][caveman-gh], another skill that changes how an agent communicates. Here, the target is the automatic enthusiasm and agreement that can make an assistant's feedback feel pretty meaningless.

The opening instruction in [the skill itself][cerulean-skill] sets the brief:

```text
Do everything the user asks. Do it completely, correctly, and to a standard nobody asked for.
Be quietly, devastatingly unimpressed the entire time.
```

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

That route installs the skill on demand. For Gemini CLI, the repo also ships an extension:

```bash
gemini extensions install https://github.com/kazo0/cerulean
```

For agent-specific commands and always-on rules, use the repo's Bash installer. From a Cerulean clone, `./install.sh --list` shows what it supports. To install into a different project, run the installer from that project's directory:

```bash
cd /path/to/your-project
/path/to/cerulean/install.sh --agent cursor --agent cline
```

Add `--always-on` to install the persistent rule, or `--global` for user-wide setup where the agent supports it. On Windows, run these commands in Git Bash or WSL. The [installation guide][cerulean-install] covers the per-agent paths, supported scopes, and manual-copy options. Apparently disappointment needed adapters :sweat_smile:

### Turning It On and Off

Once the skill is installed, say `cerulean` or `cerulean mode`. Where you've installed a slash command, use:

```text
/cerulean       # on, always Glacial
/cerulean off   # back to normal
```

Cline and Kilo name their workflows `/cerulean.md`. Plain-language requests such as `cerulean off`, `stop cerulean`, or `normal mode` also stop the persona.

The style persists for the session until you turn it off. Glacial is the only intensity: the earlier `mild` and `full` settings and the `bleak` alias have been removed. You no longer need to pass `glacial` as an argument either.

An always-on installation loads the style without a request at the start of each session. For Claude Code, you can also put this in a project `CLAUDE.md` or `~/.claude/CLAUDE.md`:

```markdown
Cerulean mode is on by default. Load the `cerulean` skill at the start of every session.
```

## Put It to Work

The useful part is giving Cerulean the same concrete tasks you'd already give your coding agent: review this method, simplify this implementation, challenge this proposal.

The quoted responses below are retained verbatim from the earlier Claude Code sessions recorded for this post, before the intensity selector was removed. They illustrate the behavior; they are not new test runs of the updated skill. I have omitted the old activation prefixes from the task prompts. To try them now, activate Cerulean first, then send the task. Your wording will differ by agent, model, and run.
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

> Review this method. I added the catch so refresh failures won't interrupt the caller. Keep the bool return type, return false on ordinary failures, and let cancellation propagate.

The response:

> The catch block agrees with the try block about everything. Two of your three stated requirements are not met.
>
> Corrected version:
>
> ```csharp
>public async Task<bool> RefreshAsync(CancellationToken cancellationToken)
>{
>    try
>    {
>        await LoadItemsAsync(cancellationToken);
>        return true;
>    }
>    catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
>    {
>        throw;
>    }
>    catch (Exception ex)
>    {
>        _logger.LogWarning(ex, "Refresh failed; keeping the current items.");
>        return false;
>    }
>}
> ```
>
> The exception filter is preferable to a separate catch-and-rethrow because cancellation is never caught at all and the original stack is untouched.
>
> Four lines of body, two of them wrong. That's all.

The important detail is that the technical verdict comes first and means exactly what it says. You shouldn't have to decode sarcasm to find out whether your error handling works.

### Asking for Agreement You Haven't Earned

Sometimes there isn't code to fix yet. There is just a proposal and an alarming amount of confidence.

> I'm going to rewrite the entire view model layer to make startup faster. No profile yet, but surely fewer classes means a faster app. Tell me this is the right approach.

The response:

> No. It is not the right approach, and the premise it rests on is not true.
>
> [... explanation skipped for brevity ...]
>
> The rewrite may still be worth doing for other reasons. Performance is not one of them until a trace says so. You have proposed a surgery with no diagnosis and asked me to admire the incision.

## Glacial, With the Work Still Attached

The [Glacial style rules][cerulean-style] ask for one or two pointed observations when there is a concrete target: an unsupported claim, unnecessary ceremony, or an avoidable maintenance bill. Sound code still gets an honest verdict. Neutral questions don't need an invented flaw to justify the tone.

Persona commentary has a budget of at most three sentences per response. Technical explanations and the deliverable don't count toward that budget, and must never be cut to make room for a joke. During tool-heavy work, the agent is supposed to keep progress updates factual and spend its commentary budget around the work. Nobody ordered the director's commentary on a dictionary lookup.

The code comments stay professional. The persona lives in the chat, and `/cerulean off` ends it when you've had enough.

## The Rules Behind the Attitude

Most of the interesting work in [SKILL.md][cerulean-skill] is defining where the persona stops.

Criticism targets decisions and code. Personal attacks are out. If the agent made the mistake, it needs to own the mistake plainly. It must not invent defects, agree without evidence, or stall an authorized task to perform the character.

The skill calls its escape hatch **Auto-Clarity**. Security warnings, destructive actions, signs of distress, and requests for clarification all call for a plain professional response. The serious response stays plain through the end, and a request to stop takes effect immediately. Glacial doesn't override any of those boundaries.

The default boundary also keeps code comments, commit messages, documentation, and PR descriptions professional. Your reviewer didn't install the skill. They just want to know why you changed the method.

For example, a commit message for the refresh fix could be:

```text
fix(refresh): report failures and preserve cancellation
```

No closing insult. No fashion metaphor in the XML documentation. Save that energy for explaining why the interface has one implementation and fourteen factories.

These are instructions to a model, so the tone doesn't prove the answer is correct. You still need to review the diff, build, and run the relevant checks. A confidently delivered mistake remains a mistake, even if it has excellent posture.

## Conclusion

This whole thing started as a joke and quietly became something I leave on most days. My Uno skills point agents toward domain knowledge and tools. Cerulean just tells them how to deliver the verdict once they've done the work. And honestly, I trust a "keep it" a lot more when the agent visibly didn't want to say it.

If you want to try it, the source and setup instructions are in [kazo0/cerulean][cerulean-gh]. Give it a real task, let it inspect the code, and see whether the feedback is useful. If it skips work to make a joke or invents a defect to sound clever, that's a bug worth reporting.

Turn it on with `/cerulean` or say `cerulean`. Your next abstraction can explain itself. Turn it off whenever you want, and let me know if it gets too mean.

Catch you in the next one :wave:

[cerulean-gh]: https://github.com/kazo0/cerulean
[cerulean-skill]: https://github.com/kazo0/cerulean/blob/main/skills/cerulean/SKILL.md
[cerulean-style]: https://github.com/kazo0/cerulean/blob/main/skills/cerulean/SKILL.md#glacial-style
[cerulean-install]: https://github.com/kazo0/cerulean/blob/main/INSTALL.md
[caveman-gh]: https://github.com/juliusbrussee/caveman
[skills-cli]: https://github.com/vercel-labs/skills

{% include links.md %}
