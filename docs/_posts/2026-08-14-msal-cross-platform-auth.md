---
title: "MSAL Auth in Uno Platform, With and Without Uno.Extensions"
category: uno-general
header:
  teaser: /assets/images/msal-auth/hero.png
  og_image: /assets/images/msal-auth/hero.png
tags: [uno-platform, uno, msal, authentication, entra, uno-extensions, security]
---

Authentication is one of those things every real app needs and almost nobody enjoys wiring up. Sign in with a Microsoft or work account, get a token, call an API, keep the token fresh, sign out. On a single platform it's a known quantity. Across Android, iOS, WebAssembly, and desktop from one codebase, it gets a little more interesting, because each of those platforms has its own idea of how a browser-based sign-in redirect comes back into your app.

The good news is that MSAL, Microsoft's Authentication Library, works great with Uno Platform, and there are two solid ways to do it. You can drive MSAL.NET yourself, or you can let `Uno.Extensions.Authentication.MSAL` do most of the driving for you. I built a sample app for each so I could compare them honestly, and this post walks through both.

- The manual one: [Authentication.MsalDemo][gh-msaldemo]
- The Uno.Extensions one: [Authentication.MsalExtensionsDemo][gh-msalext] (currently an [open PR][pr])

Let's start with the part that's identical no matter which path you take.

## The Azure Side Is the Same Either Way

Both approaches talk to the same identity provider, so the setup in the [Microsoft Entra admin center][entra] is the same. You register an app, and you tell it how your app is allowed to sign people in.

1. Register a new application under **App registrations**.
2. Copy the **Application (client) ID**. That's the one value you have to paste into the sample.
3. Under **Authentication**, turn on **Allow public client flows**. A mobile or desktop app can't keep a secret, so it signs in as a public client. Skip this and you get a confusing `unauthorized_client` error.
4. Add the **Microsoft Graph** delegated permission **`User.Read`**, which is what both samples use to fetch the signed-in user.
5. Register **one redirect URI per platform**. This is the part people trip on.

The redirect URI is the address the identity provider sends the browser back to once the user has signed in, and each head needs its own:

| Head | Redirect URI | Register it as |
| --- | --- | --- |
| Desktop | `http://localhost` | Mobile and desktop |
| Android | `msal<ClientId>://auth` | Mobile and desktop, custom URI |
| iOS | `msauth.<bundle-id>://auth` | iOS/macOS |
| WebAssembly | `http://localhost:5000/authentication/login-callback.htm` | Single-page application |

A couple of these bite people. The WebAssembly URI has to be registered specifically as a **Single-page application**, because only that platform type gets the CORS headers the browser needs to redeem the token. And both samples print the exact redirect URI they're going to use right there in the running app, so the reliable move is to copy it out of the app rather than type it by hand.

With that done, the two approaches diverge. Here's the same job, twice.

## Option 1: MSAL.NET By Hand

The manual sample pulls in two packages: `Microsoft.Identity.Client`, which is MSAL.NET itself, and `Uno.WinUI.MSAL`, which provides the helpers that bridge MSAL to Uno's windows and activities. The only UnoFeature it needs is `SkiaRenderer`.

You own the `IPublicClientApplication`. You build it, you keep it, you call it. The core looks like this:

```csharp
var app = PublicClientApplicationBuilder
    .Create(MsalConfig.ClientId)
    .WithAuthority(AzureCloudInstance.AzurePublic, MsalConfig.Tenant)
    .WithRedirectUri(PlatformSupport.RedirectUri)
    .Build();
```

Then you write the token flow. The pattern you want is cache-first: try to get a token silently, and only pop a browser if that fails. MSAL signals "I need the user" by throwing a specific exception, which you treat as normal control flow rather than an error:

```csharp
try
{
    // Reuse an existing session if we have one.
    return await app.AcquireTokenSilent(MsalConfig.Scopes, account).ExecuteAsync(ct);
}
catch (MsalUiRequiredException)
{
    // Expected: no cached token, so fall back to interactive sign-in.
    return await app.AcquireTokenInteractive(MsalConfig.Scopes)
        .WithPrompt(Prompt.SelectAccount)
        .WithUnoHelpers()
        .ExecuteAsync(ct);
}
```

Signing out is manual too. There's no server-side session to kill here, so you enumerate the cached accounts and remove each one:

```csharp
foreach (var account in await app.GetAccountsAsync())
{
    await app.RemoveAsync(account);
}
```

None of that is Uno-specific, really. It's the same MSAL.NET you'd write in any .NET app, and if you already know MSAL it will feel like home. The Uno-specific cost is the platform plumbing that catches the sign-in redirect, and there's a fair amount of it because each OS does it differently.

On **Android**, the redirect comes back as an intent, so you need a small activity that catches it, wired to a scheme built from your client id:

```csharp
[Activity(Exported = true, LaunchMode = LaunchMode.SingleTask, NoHistory = true)]
[IntentFilter([Intent.ActionView],
    Categories = [Intent.CategoryBrowsable, Intent.CategoryDefault],
    DataScheme = MsalConfig.AndroidRedirectScheme, DataHost = "auth")]
public class MsalActivity : BrowserTabActivity { }
```

You also have to forward the activity result back into MSAL from your main activity, or the app just hangs after the user signs in:

```csharp
protected override void OnActivityResult(int requestCode, Result resultCode, Intent? data)
{
    base.OnActivityResult(requestCode, resultCode, data);
    AuthenticationContinuationHelper.SetAuthenticationContinuationEventArgs(requestCode, resultCode, data);
}
```

On **iOS** the story is similar but different in shape. You need a custom app delegate that hands the callback URL to MSAL, you need to declare your URL scheme in `Info.plist`, and you need a keychain access group in your entitlements or MSAL won't even build its client:

```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.microsoft.adalcache</string>
</array>
```

On **WebAssembly** you need the static `login-callback.htm` landing page that your SPA redirect URI points at, plus a little code to resolve the browser's origin at runtime. And on **desktop** you get off easy: MSAL launches the system browser and listens on a loopback address, so `http://localhost` and nothing else.

Add it up and that's roughly a dozen platform-specific files and concerns you write and maintain by hand. It's all reasonable code, and the sample keeps each piece small, but it is unmistakably your code to own.

## Option 2: Uno.Extensions.Authentication.MSAL

Now the same app, built on `Uno.Extensions.Authentication.MSAL`. The pitch is simple: instead of constructing and calling MSAL yourself, you register it with the app host once, and then you talk to a small framework interface.

It starts with a single UnoFeature, `AuthenticationMsal`, which brings in the whole authentication pipeline. Your client id, tenant, and scopes move out of code and into `appsettings.json`:

```json
{
  "Msal": {
    "ClientId": "00000000-0000-0000-0000-000000000000",
    "TenantId": "common",
    "Scopes": [ "https://graph.microsoft.com/User.Read" ]
  }
}
```

Then you add the provider to the host builder. This one line replaces the `PublicClientApplicationBuilder`, the token flow, and the cache management from the manual version:

```csharp
var builder = this.CreateBuilder(args)
    .Configure((host, window) => host
        .UseConfiguration(config => config.EmbeddedSource<App>())
        .UseAuthentication(auth => auth
            .AddMsal(window, msal => msal.Builder(ConfigurePlatformRedirect))));
```

`AddMsal` reads your client id and scopes from that `Msal` configuration section by convention, so you don't repeat them in code. From there, your app talks to `IAuthenticationService`, injected from DI, and it never touches an MSAL type. The whole sign-in surface becomes four calls:

```csharp
await Auth.LoginAsync(dispatcher);   // interactive sign-in
await Auth.RefreshAsync();           // silent refresh
await Auth.LogoutAsync(dispatcher);  // sign out
var signedIn = await Auth.IsAuthenticated();
```

And the token cache is a framework service too. You can inject `ITokenCache` and inspect what's stored without going anywhere near MSAL's cache serialization:

```csharp
var tokens = await TokenCache.GetAsync(CancellationToken.None);
```

That is genuinely most of the app. There's no `AcquireTokenSilent`, no `MsalUiRequiredException` handling, no account enumeration on sign-out, no `IPublicClientApplication` to hold onto. The provider setup and the token lifecycle live in the host, and your UI stays small and portable.

### The Honest Part

Here's where I want to be straight with you, because it would be easy to oversell this. The Extensions package takes the MSAL flow off your plate. It does not take the operating system's redirect plumbing off your plate.

You still write the Android `BrowserTabActivity` and the `OnActivityResult` forward. You still write the iOS `OpenUrl` app delegate. On WebAssembly you still point the return URI at your callback page. All of those still call MSAL.NET's `AuthenticationContinuationHelper` directly, exactly like the manual sample does. The one piece that stays in code on the MSAL builder is the per-platform redirect URI:

```csharp
private static void ConfigurePlatformRedirect(PublicClientApplicationBuilder builder)
{
#if ANDROID
    builder.WithRedirectUri($"{MsalConfig.AndroidRedirectScheme}://auth");
#elif IOS
    builder.WithRedirectUri(MsalConfig.IosRedirectUri);
#else
    if (!PlatformHelper.IsWebAssembly)
    {
        builder.WithRedirectUri(MsalConfig.DesktopRedirectUri);
    }
#endif
}
```

So the Extensions package is not "zero platform code." It's "none of the MSAL boilerplate, and the same native redirect glue you'd have written anyway." Desktop is close to free either way, and the mobile heads are where both approaches still ask something of you.

## So What Actually Moves

If you line the two up, the split is pretty clean.

The Extensions version deletes the provider construction, the silent-then-interactive token dance, the sign-out account cleanup, and the token cache handling. That's the bulk of the fiddly, easy-to-get-subtly-wrong code, and it's the part I'm happiest to hand off. It moves your client id, tenant, and scopes into configuration, and it hands you `IAuthenticationService` and `ITokenCache` through dependency injection.

What stays with you in both versions is the Azure app registration, the per-platform redirect URIs, and the native redirect-capture wiring for Android and iOS. That's not a framework limitation so much as the reality of how mobile sign-in redirects work.

I touched on the Uno.Extensions authentication stack briefly in my [Uno Chefs login walkthrough]({% post_url 2025-07-02-chefs-login %}), where the Chefs app uses a custom provider. MSAL is just another provider in that same pipeline, which is a nice thing about the design: the shape of your app code doesn't change based on who's actually issuing the tokens.

## A Couple of Platform Gotchas

Regardless of which path you pick, a few things are worth knowing before you lose an afternoon to them.

WebAssembly is the fussiest head. Interactive sign-in in the browser depends on the redirect and the renderer in ways that have been moving recently, so if you're on WASM, read the sample's setup notes and check which Uno version you're on rather than assuming it just works. The silent path and Graph calls are fine, it's the first interactive sign-in that's delicate.

On iOS, that keychain access group is not optional. Leave it out and MSAL throws before you ever see a screen. And if you change it, you need a clean iOS rebuild, because the native link caches it.

Finally, the redirect URI you register has to match the one your app sends, character for character. This is the single most common reason sign-in fails, which is exactly why both samples print their computed redirect URI on screen. Copy from there. Both samples ship with a placeholder client id and a `MSAL-SETUP.md` that walks the whole registration, so you can run them first and fill in the real value once you see what they expect. For the framework-level details, the [Uno.Extensions MSAL how-to][msal-howto] is the reference.

## Which One Should You Use

If you're already building on the Uno.Extensions host, with configuration and dependency injection, reach for `Uno.Extensions.Authentication.MSAL`. It fits that world naturally, it keeps your auth setup declarative, and it deletes the most error-prone code. This is where I'd start for a new app.

If you're not using the Uno.Extensions host, or you need fine-grained control over the MSAL calls, custom cache behavior, or an unusual flow, drive MSAL.NET yourself. It's more code, but it's all in the open and there's nothing between you and the library.

Either way, the Azure setup and the native redirect glue are the same, so switching later is far less scary than it sounds.

## Conclusion

Cross-platform auth has a reputation for being miserable, and MSAL on Uno mostly puts that reputation to rest. The manual route gives you every knob and asks you to wire up the platform plumbing yourself. The Uno.Extensions route hands the MSAL flow to the framework and lets you talk to a tidy `IAuthenticationService` instead, while still leaving the native redirect bits in your hands. Both are real, both are shipping in the samples repo, and now there's a working example of each to start from.

Go poke at the [manual sample][gh-msaldemo] and the [Uno.Extensions sample][gh-msalext], and if you get stuck on a redirect URI, know that you're in very good company. Come find me in the [Uno Discord][uno-discord] if you do.

Catch you in the next one :wave:

## Additional Resources

- [Authentication.MsalDemo sample (manual MSAL)][gh-msaldemo]
- [Authentication.MsalExtensionsDemo sample (Uno.Extensions)][gh-msalext]
- [Uno.Extensions MSAL Authentication how-to][msal-howto]

[gh-msaldemo]: https://github.com/unoplatform/Uno.Samples/tree/master/UI/Authentication.MsalDemo
[gh-msalext]: https://github.com/unoplatform/Uno.Samples/pull/944
[pr]: https://github.com/unoplatform/Uno.Samples/pull/944
[entra]: https://entra.microsoft.com/
[uno-discord]: https://platform.uno/discord
[msal-howto]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Authentication/HowTo-MsalAuthentication.html
{% include links.md %}
