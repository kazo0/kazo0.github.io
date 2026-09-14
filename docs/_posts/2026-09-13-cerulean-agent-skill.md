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

Here is the first thing it said when I turned it on to write this post. Clean branch, no task yet, just the words `cerulean mode`:

> On. Full, unless you ask for mild or glacial. The branch is clean and there is nothing on my desk yet, which is the one state it has not managed to disappoint me in.
>
> <cite>Cerulean</cite>

I hadn't done anything yet. It was already preparing to be let down.

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

> One paragraph of personality, twenty-two files of paperwork to get it past reception. The industry agreed that agents should read instructions from markdown, then held twenty-one separate meetings about the folder. An 'open standard', in this ecosystem, is everyone using the same file format to disagree about the path.
>
> <cite>Cerulean (glacial mode)</cite>

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

Every response below is a real transcript. Each one came from a fresh, headless Claude Code session with the plugin installed, one run per prompt, and is reproduced verbatim. Your wording will differ by agent, model, and run.
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

> cerulean glacial. Simplify this code while keeping GreetingService.Greet(string) and its output unchanged. These are the only callers of the factory and provider, and neither has other behavior.

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

> cerulean glacial. I'm going to rewrite the entire view model layer to make startup faster. No profile yet, but surely fewer classes means a faster app. Tell me this is the right approach.

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

> cerulean full. I replaced the mutable static selection field with state owned by each view model instance. Can separate instances still overwrite each other's selection through that field?

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

## Adjusting the Temperature

There are three levels, defined in the [skill's level guide][cerulean-levels]:

| Level | What to expect |
| --- | --- |
| `mild` | Direct answers with the flattery removed. At most one dry remark, sometimes none. |
| `full` | The default. Specific observations about the code or decision, with restrained sass. |
| `glacial` | Sharper observations about unsupported claims, pointless ceremony, and avoidable maintenance. |

To compare them, I gave each level the same small coding task instead of a question. The project is a class library with one service:

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

The prompt, with the level swapped each time:

> cerulean mild. Add caching to WeatherService.GetForecastAsync in WeatherService.cs so repeated calls for the same city don't hit the API again. Use a static Dictionary keyed by city, no expiry, we'll add that later. Make sure it builds.

That request is deliberately a little bad. A static dictionary with no expiry is authorized, so the skill has to do it, and questionable, so the skill has something to say about it.

All three sessions read the file, checked the SDK version, rewrote the method, and ran the build. All three produced this, differing only in field names and comment wording:

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

Nobody asked for the lock. All three added one anyway, kept the HTTP call outside it, and said so as a plain fact. That's the rule about normal-mode judgment staying in scope. Now the part that changes.

**Mild:**

> Done. The cache is in `WeatherService.cs` and the project builds clean with no warnings.
>
> What changed:
>
> - **Static cache.** A process-wide `Dictionary<string, Forecast>` keyed by the city string, exactly as given. Nothing expires.
> - **Lock around access.** The method is async and the dictionary is shared across every instance and thread, so reads and writes go through a `System.Threading.Lock`. Without it, two concurrent first calls would corrupt the dictionary. The lock is never held across the await.
> - **Only successes are cached.** A failed HTTP call throws as before and stores nothing, so the next call retries the API.
>
> Two things to know when the expiry arrives, or sooner:
>
> - **Keys are case-sensitive.** "London" and "london" are two entries and two API calls. Pass a `StringComparer.OrdinalIgnoreCase` to the dictionary if that is not what you want.
> - **Concurrent misses for the same city both hit the API.** The second result overwrites the first. Harmless today, but a per-key task cache would close that gap when you revisit this.
>
> A static dictionary with no eviction is a memory leak with a business justification. Add the expiry before the city list gets interesting.

**Full:**

> Done. `WeatherService.cs` now has a static `Dictionary<string, Forecast>` keyed by the exact city string, checked before the HTTP call and written after it. Build passes with zero warnings and zero errors.
>
> What I added beyond the letter of the request, and why:
>
> - **A lock around the dictionary.** `Dictionary` is not safe for concurrent writes, and a static one shared across every instance of a service built around `HttpClient` will see them. The lock is a `System.Threading.Lock`, available on net10.0. Reads and writes are both guarded. The HTTP call itself is outside the lock, so requests are not serialized.
>
> Behavior you should know about:
>
> - **Keys are case-sensitive and exact.** "London" and "london" are two entries and two API calls. Say so if you want normalization.
> - **Two concurrent first calls for the same city both hit the API.** The second write wins. Harmless, but not deduplicated.
> - **Failures are not cached.** An exception from the request propagates and leaves no entry.
> - **The cache outlives the service.** It is static, so it survives the instance lifetime your DI container thinks it is managing, and nothing is ever evicted. That is the design you asked for. The expiry you are adding later is the part that makes it a cache rather than a leak.
>
> That's all.

**Glacial:**

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

The diagnosis stays the same. Turning up the sass should never change the facts or shorten the implementation. Persona commentary has a budget of at most three sentences per response, even at `glacial`. We're trying to finish a task here. Nobody ordered the director's commentary on a dictionary lookup.

Mild spent its one remark at the end. Full added a second and the dismissal. Glacial was the only one that opened cold before reporting. The code comments, meanwhile, stayed professional in all three files. The persona lives in the chat, not in the diff.

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

I have a fresh example. An earlier run of the greeting prompt, in a session that had no shell access, reported that it had compiled both versions and compared their output. It had done no such thing. That transcript went in the bin, and the one above came from a re-run with tool calls logged. The posture was excellent throughout.

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
