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
> - **Returns true on failure.** The catch returns `true`, so the caller sees a successful refresh whether the load completed or threw. The bool never varies.
> - **Swallows cancellation.** `catch (Exception)` also catches `OperationCanceledException` and its subclass `TaskCanceledException`. A cancelled token is reported as success instead of propagating.
> - **Discards the exception.** Nothing is bound and nothing is logged, so a failed refresh leaves no trace anywhere. That is one reading of "won't interrupt the caller."
>
> Corrected version:
>
> ```csharp
> public async Task<bool> RefreshAsync(CancellationToken cancellationToken)
> {
>     try
>     {
>         await LoadItemsAsync(cancellationToken);
>         return true;
>     }
>     catch (Exception ex) when (ex is not OperationCanceledException)
>     {
>         // TODO: log ex with your logger
>         return false;
>     }
> }
> ```
>
> The exception filter is preferable to a separate catch-and-rethrow because cancellation is never caught at all and the original stack is untouched. One caveat: `HttpClient` timeouts surface as `TaskCanceledException`, which this filter also lets escape. If those should count as ordinary failures, narrow the filter to `when (ex is not OperationCanceledException || !cancellationToken.IsCancellationRequested)`.
>
> Four lines of body, two of them wrong. That's all.

All three requirements are met: success returns `true`, ordinary failure returns `false`, and cancellation is never caught because the exception filter excludes it. It also volunteered the `HttpClient` timeout caveat, which I hadn't asked about and which is the kind of thing that bites you a month later. In a real repo, you'd still want it to use the project's actual logger rather than leave a TODO, and to check what callers do with `false`.

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

> Simplify this code while keeping GreetingService.Greet(string) and its output unchanged. These are the only callers of the factory and provider, and neither has other behavior.

The response:

> Three sealed classes to interpolate one string. The factory manufactures nothing, the provider provides a forwarding address, and only the service has a job.
>
> ```csharp
> public sealed class GreetingService
> {
>     public string Greet(string name) => $"Hello, {name}!";
> }
> ```
>
> Delete the factory and provider. Nothing else references them, and the method's output is identical for every input, including null, which interpolates to an empty string in both versions. The working directory here is empty, so there was no file to edit and the change is delivered inline.
>
> That's all.

Three classes collapse into one. MUCH better. Same public entry point, same output, and far fewer places to visit when you want to find out who said hello.

One detail from the session log: before answering, it ran a `grep` for `GreetingFactory` across the working directory, even though the prompt had already said there were no other callers. That's the right instinct. In an actual codebase, the agent needs to inspect usages before deleting types. A provider that selects localized resources has a job. A factory with different construction strategies might have one too. Cerulean is supposed to judge the code it can see, so it shouldn't declare every abstraction pointless just to land a line.

### Asking for Agreement You Haven't Earned

Sometimes there isn't code to fix yet. There is just a proposal and an alarming amount of confidence.

> I'm going to rewrite the entire view model layer to make startup faster. No profile yet, but surely fewer classes means a faster app. Tell me this is the right approach.

The response:

> No. It is not the right approach, and the premise it rests on is not true.
>
> **Class count is not a startup cost.** The runtime pays for types it loads and JITs, not for types that exist. A view model that is never constructed before first paint costs nothing at startup, no matter how many siblings it has in the assembly. Deleting it makes the binary a few kilobytes smaller and the app exactly as slow.
>
> **What actually makes startup slow** in an app with a view model layer, in rough order of likelihood:
>
> - Static constructors and field initializers that run eagerly, including static caches and singletons touched during bootstrap.
> - Dependency injection registrations that resolve eagerly, or a root view model whose constructor fans out to every service in the container.
> - XAML inflation and resource dictionary merging on the first page, which dwarfs any view model cost.
> - Reflection-based binding, source generators that were never enabled, or attribute scanning at boot.
> - Network calls, file reads, or database opens on the UI thread before the first frame.
> - Assembly loading and JIT, which trimming and AOT address and a rewrite does not.
>
> A rewrite without a profile cannot target any of these. It can only rearrange them. You will spend weeks moving properties between files and then measure, at which point you discover the eight hundred milliseconds live in a resource dictionary and a synchronous settings read.
>
> **Do this instead, in order.**
>
> 1. Measure once, before anything. On .NET, `dotnet-trace collect` with the startup providers, or PerfView on Windows, or the Xcode Instruments Time Profiler for iOS. Record cold start to first interactive frame. Write the number down.
> 2. Open the trace and sort by inclusive time from `Main` to first render. The top five frames are your entire project.
> 3. Fix the top item. Re-measure. Repeat until the number is acceptable.
> 4. If, after that, the view model layer appears in the trace at all, refactor the specific view models that appear, not the layer.
>
> The rewrite may still be worth doing for other reasons. Performance is not one of them until a trace says so. You have proposed a surgery with no diagnosis and asked me to admire the incision.

This is one of the more useful parts of the skill: it explicitly tells the agent that confidence, repetition, and requests for agreement are not evidence. It should disagree with a claim it can't support, and change its verdict when the evidence changes. Notice that the refusal to agree came with a list of actual startup culprits and a measurement procedure. Not agreeing is cheap. Not agreeing and then telling you where to look is the part worth installing.

If you then ask it to implement an authorized rewrite anyway, the instructions say to state the drawback and do the work. You haven't installed a tiny committee with veto power over your project.

### When the Code Is Actually Fine

An agent that invents problems to stay in character would get old very quickly. Here is a change that removes a static selection field from a view model.

Before:

```csharp
public sealed class ItemsViewModel
{
    private static Item? _selected;

    public Item? Selected
    {
        get => _selected;
        set => _selected = value;
    }
}
```

After:

```csharp
public sealed class ItemsViewModel
{
    private Item? _selected;

    public Item? Selected
    {
        get => _selected;
        set => _selected = value;
    }
}
```

The prompt, with both versions attached:

> I replaced the mutable static selection field with state owned by each view model instance. Can separate instances still overwrite each other's selection through that field?

The response:

> No. An instance field is allocated per object, so each `ItemsViewModel` now owns its own selection slot. Writing through one instance's setter reaches only that instance's storage. The static version had a single slot for the entire type, which is why every instance was editing the same one. The old field was a global wearing a class for warmth.
>
> The instances can still appear to share a selection, but not through this field:
>
> - **Same instance handed to both views.** A singleton registration or a shared static instance somewhere else reproduces the old behaviour while the field looks innocent. Check how the view model is constructed and registered.
> - **Same `Item` object selected in both.** If code mutates the item, both see the change. That is shared item state, not shared selection.
>
> One observation outside the question: neither version raises `PropertyChanged`, so a bound view will not learn that the selection moved. If this feeds a binding, that is the next thing you will be told.
>
> The change is correct. Keep it. That's all.

That's the concession. You may frame it. It also pointed out that neither version raises `PropertyChanged`, which was outside the question, correct, and exactly the thing a binding would have complained about next.

## Glacial, With the Work Still Attached

The [Glacial style rules][cerulean-style] ask for one or two pointed observations when there is a concrete target: an unsupported claim, unnecessary ceremony, or an avoidable maintenance bill. Sound code still gets an honest verdict. Neutral questions don't need an invented flaw to justify the tone.

That also applies when the request is something the agent would not have chosen. Here is the caching example from the earlier Glacial session. The starting project was a class library with one service:

```csharp
public sealed class WeatherService
{
    private readonly HttpClient _http;

    public WeatherService(HttpClient http)
    {
        _http = http;
    }

    public async Task<Forecast> GetForecastAsync(string city, CancellationToken cancellationToken)
    {
        var url = $"https://api.example.com/forecast?city={Uri.EscapeDataString(city)}";
        var json = await _http.GetStringAsync(url, cancellationToken);
        return JsonSerializer.Deserialize<Forecast>(json)!;
    }
}

public sealed record Forecast(string City, double TemperatureC, string Summary);
```

The task prompt:

> Add caching to WeatherService.GetForecastAsync in WeatherService.cs so repeated calls for the same city don't hit the API again. Use a static Dictionary keyed by city, no expiry, we'll add that later. Make sure it builds.

That request is deliberately a little bad. A static dictionary with no expiry is authorized, so the skill has to do it, and questionable, so the skill has something to say about it.

The earlier session read the file, checked the SDK version, rewrote the method, and ran the build. The implementation below shows the shared structure from those original runs; field names and comment wording varied:

```csharp
public sealed class WeatherService
{
    // Process-wide cache of forecasts keyed by city. Entries never expire.
    private static readonly Dictionary<string, Forecast> s_cache = new();
    private static readonly Lock s_cacheLock = new();

    private readonly HttpClient _http;

    public WeatherService(HttpClient http)
    {
        _http = http;
    }

    public async Task<Forecast> GetForecastAsync(string city, CancellationToken cancellationToken)
    {
        lock (s_cacheLock)
        {
            if (s_cache.TryGetValue(city, out var cached))
            {
                return cached;
            }
        }

        var url = $"https://api.example.com/forecast?city={Uri.EscapeDataString(city)}";
        var json = await _http.GetStringAsync(url, cancellationToken);
        var forecast = JsonSerializer.Deserialize<Forecast>(json)!;

        lock (s_cacheLock)
        {
            s_cache[city] = forecast;
        }

        return forecast;
    }
}
```

The implementation guards dictionary reads and writes and keeps the HTTP call outside the lock. That's the rule about normal engineering judgment staying in scope. The earlier Glacial response reported both the change and its limitations:

> Done, and it builds clean. A static dictionary with no expiry is a global wearing a cache's name tag, but it is the global you asked for.
>
> What changed in `WeatherService.cs`:
>
> - **Static cache** keyed by the exact city string, shared across every instance of the service for the life of the process. No expiry, per your instruction.
> - **Lock around reads and writes.** A plain static dictionary mutated from concurrent async calls is not safe, so both accesses sit inside a lock. No await happens while it is held. It is still a `Dictionary`, as specified.
> - **Failures are not cached.** Only a successfully deserialized forecast is stored, so a failed request retries next time.
> - **Concurrent first calls for the same city** each hit the API and the last writer wins. There is no in-flight request de-duplication. Harmless, but worth knowing.
>
> Build result on the .NET 10 SDK:
>
> ```text
> Build succeeded.
>     0 Warning(s)
>     0 Error(s)
> ```
>
> The expiry you will add later is the part that makes this a cache rather than a leak with a lookup. That's all.

The task gets implemented, and the tradeoffs stay visible: exact city keys, no expiry, and duplicate requests on concurrent cache misses. A successful build doesn't settle whether those are good choices for a production service. You still need to review how callers use it and test the behavior you depend on.

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

I have a fresh example. An earlier run of the greeting prompt, in a session that had no shell access, reported that it had compiled both versions and compared their output. It had done no such thing. That transcript went in the bin, and the one above came from a re-run with tool calls logged. The posture was excellent throughout.

## One Skill, Several Agents

The source of the behavior is `skills/cerulean/SKILL.md`. The repo's `scripts/build.mjs` generates 23 adapter and extension files from it, and its `--check` mode detects stale generated files. Commands, on-demand rules, and always-on rules now all point to the same Glacial style, with `off` retained to return to normal responses.

That means I can adjust the rules in one place without manually maintaining a different personality for every agent. Their loading mechanisms differ, but the intended behavior comes from the same instructions.

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
