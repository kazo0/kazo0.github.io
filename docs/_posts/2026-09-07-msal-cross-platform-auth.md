---
title: "MSAL Auth in Uno Platform with Uno.Extensions"
category: uno-general
tags: [uno-platform, uno, msal, authentication, entra, uno-extensions, security]
---

Authentication has a familiar checklist: sign in, get a token, call an API, refresh the token, sign out. Across Android, iOS, WebAssembly, and desktop, the extra work is getting the browser's sign-in response back into your app.

`Uno.Extensions.Authentication.MSAL` connects Microsoft's Authentication Library to Uno.Extensions' authentication services. It handles token acquisition and caching, while your app uses `IAuthenticationService` to sign in, refresh the session, and sign out.

The [Authentication.MsalExtensionsDemo sample][gh-msalext] walks through that flow and calls Microsoft Graph with the resulting access token. This post follows its configuration, the platform callbacks you still need to wire up, and where the tokens live.

This post follows Uno.Extensions `main` and the sample on `master`, checked September 7, 2026. The sample uses prerelease packages: Uno.Sdk `6.8.0-dev.23` and Uno.Extensions `7.4.0-dev.29`. Start with its pinned versions when following along.
{: .notice--info}

## The Entra Setup

Start with a [Microsoft Entra app registration][entra]:

1. Register an application and choose its **Supported account types**. Match those to your tenant setting: `common` for work/school and personal Microsoft accounts, `organizations` for work/school accounts, `consumers` for personal accounts, or a specific tenant ID for a single organization. The sample's development configuration uses `consumers`.
2. Copy the **Application (client) ID** into the sample. These are public clients; no client secret belongs in the app.
3. Add the **Microsoft Graph** delegated permission **`User.Read`**, which the sample uses to call `/me`.
4. Register the redirect URIs for the platforms you plan to run.

The sample guide also enables **Allow public client flows**. That setting is the fallback for flows without a redirect URI, such as device code flow. For these browser sign-ins, Entra determines the client type from the registered redirect URI, so the toggle cannot fix a URI registered under the wrong platform. [Microsoft explains that distinction here][public-client-flows].

The redirect URI is where Entra sends the authorization response after sign-in:

| Platform | Redirect URI | Register it as |
| --- | --- | --- |
| Desktop (Skia) | `http://localhost` | Mobile and desktop |
| Android | `msal{ClientId}://auth` | Mobile and desktop, custom URI |
| iOS | `msauth.{BundleId}://auth` | iOS/macOS |
| WebAssembly | `http://localhost:5000/authentication-callback` | Single-page application |

The Android entries are custom URIs under **Mobile and desktop**, matching the sample's system-browser flow. The portal's Android platform option produces a different URI based on the package name and signing certificate.

WebAssembly needs **Single-page application** registration so the browser can redeem the authorization code with CORS. Use your actual hosting origin outside local development, with HTTPS. The sample displays the redirect URI to register; copy it from there. Entra [ignores the port when matching `localhost` URIs][redirect-rules], but the path still matters.

## Register the MSAL Provider

With Uno.Extensions, you register the provider with the host and use `IAuthenticationService`. Add `AuthenticationMsal` to the app's UnoFeatures alongside its hosting and configuration setup.

{% include local-video.html src="/assets/images/msal-cross-platform-auth/extensions-flow.mp4" poster="/assets/images/msal-cross-platform-auth/extensions-signin.png" caption="The Extensions sample on macOS: silently refresh the existing session, call Microsoft Graph, then clear local sign-in state. Redacted mode is enabled throughout." %}

The Extensions sample puts this configuration in **`appsettings.development.json`**:

```json
{
  "MsalAuthentication": {
    "ClientId": "00000000-0000-0000-0000-000000000000",
    "TenantId": "consumers",
    "Scopes": [ "User.Read" ]
  }
}
```

Its host explicitly selects the Development environment in Debug builds. The relevant registration is:

```csharp
var builder = this.CreateBuilder(args)
    .Configure((host, window) => host
#if DEBUG
        .UseEnvironment(Environments.Development)
#endif
        .UseConfiguration(config => config.EmbeddedSource<App>())
        .UseAuthentication(auth => auth
            .AddMsal(window, name: "MsalAuthentication")));
```

The section name matches the `name:` argument. Without that argument, `AddMsal(window)` uses **`Msal`**. For Release builds, put the client ID, tenant, and scopes in `appsettings.json`. These files are embedded resources, so rebuild after editing them.

## Sign In, Refresh, and Sign Out

Your UI or view model can inject `IAuthenticationService` and an `IDispatcher` for interactive sign-in. Its operations are:

```csharp
await Auth.LoginAsync(dispatcher);   // silent first, interactive if needed
await Auth.RefreshAsync();          // silent only
await Auth.LogoutAsync(dispatcher);  // clear local sign-in state
var signedIn = await Auth.IsAuthenticated();
```

These calls return booleans; handle their results, cancellation, and exceptions in your UI. `IsAuthenticated()` checks whether Uno's token cache has entries, not whether a token is still valid at the server. `RefreshAsync()` attempts silent renewal for an existing session; it never opens a browser and is not a background refresh timer. Current `main` preserves cached tokens on transient refresh failures, so its result alone is not proof that a new token was obtained.

`LogoutAsync()` performs **local sign-out**: it clears the cached accounts and tokens, but leaves the identity provider's browser session intact. The next interactive sign-in may complete without asking for credentials again.

## Call Microsoft Graph

Inject `ITokenCache` to read the access token exposed by the provider:

```csharp
var tokens = await TokenCache.GetAsync(CancellationToken.None);
var accessToken = tokens.TryGetValue(TokenCacheExtensions.AccessTokenKey, out var token)
    ? token
    : null;
```

That dictionary is Uno's token cache. MSAL keeps its account and refresh-token state separately; the provider handles the connection between them. The sample sends the access token to `https://graph.microsoft.com/v1.0/me` in an `Authorization: Bearer` header.

<figure>
  <a href="{{ '/assets/images/msal-cross-platform-auth/extensions-graph.png' | relative_url }}"><img src="{{ '/assets/images/msal-cross-platform-auth/extensions-graph.png' | relative_url }}" alt="Uno.Extensions MSAL sample displaying HTTP 200 from Microsoft Graph with profile details and JSON string values hidden."></a>
  <figcaption>Microsoft Graph returns HTTP 200 using the access token exposed through Uno.Extensions' ITokenCache. Redacted mode hides the profile details and JSON string values.</figcaption>
</figure>

## What the Provider Handles

Current Uno.Extensions `main` constructs the client, applies the Uno helpers, acquires tokens, and removes cached accounts on sign-out. It also derives the platform redirect conventions shown above. A `RedirectUri` in configuration overrides the convention, and a `Builder(...)` callback runs last. `UseDefaultPlatformRedirectUri: false` disables the provider's automatic redirect selection.

You can customize interactive requests too:

```csharp
auth.AddMsal(window,
    msal => msal.InteractiveBuilder(request => request.WithPrompt(Prompt.SelectAccount)),
    name: "MsalAuthentication");
```

That callback runs only when login reaches the interactive step; it does not force a prompt when silent acquisition succeeds.

## Platform Wiring

The provider handles the token flow, but the Android activity, result forwarding, iOS delegate, URL scheme, and entitlements remain app responsibilities.

### Android

A `BrowserTabActivity` catches the redirect. Its intent-filter scheme must match the client ID in configuration:

```csharp
[Activity(NoHistory = true, LaunchMode = LaunchMode.SingleTop, Exported = true)]
[IntentFilter([Intent.ActionView],
    Categories = [Intent.CategoryDefault, Intent.CategoryBrowsable],
    DataScheme = RedirectScheme, DataHost = "auth")]
public class MsalActivity : BrowserTabActivity
{
    private const string RedirectScheme = "msal00000000-0000-0000-0000-000000000000";
}
```

Replace the placeholder with `msal` followed by your client ID. This constant must be updated separately from `appsettings.json`: attributes cannot read configuration at runtime.

The main activity also forwards the result to MSAL:

```csharp
protected override void OnActivityResult(int requestCode, Result resultCode, Android.Content.Intent? data)
{
    base.OnActivityResult(requestCode, resultCode, data);
    AuthenticationContinuationHelper.SetAuthenticationContinuationEventArgs(requestCode, resultCode, data);
}
```

### iOS

The sample registers a custom `UnoUIApplicationDelegate` with `UseUIApplicationDelegate<MsalAppDelegate>()` on the `UseAppleUIKit` builder. Its `OpenUrl` override forwards callback URLs to `AuthenticationContinuationHelper`. It also declares `msauth.{BundleId}` in `Info.plist` and grants keychain access in `Entitlements.plist`:

```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)$(CFBundleIdentifier)</string>
    <string>$(AppIdentifierPrefix)com.microsoft.adalcache</string>
</array>
```

The first entry preserves the app's own default keychain group; the second grants MSAL access to its default cache group. Missing entitlements can fail when MSAL first saves tokens or, depending on the version, while building the client.

### WebAssembly and Desktop

WebAssembly needs no redirect override or dedicated callback file in the sample. It uses `WebAuthenticationBroker`'s `/authentication-callback` URI, and its Static Web Apps configuration rewrites that path to `index.html`. Other hosts need an equivalent fallback or a page served at the callback path.

On Desktop (Skia), MSAL opens the system browser and receives the response through a loopback listener using `http://localhost` with a runtime-selected port.

## Where Tokens Live

The current Extensions provider persists MSAL's cache differently on each platform:

| Platform | MSAL cache storage |
| --- | --- |
| Android / iOS | MSAL's native persistent cache |
| Desktop (Skia) | MSAL cache helper with DPAPI, macOS Keychain, or Linux keyring |
| WebAssembly | Serialized MSAL cache through `IKeyValueStorage` |

If secure desktop storage is unavailable, Extensions keeps MSAL's cache in memory by default. An unprotected file fallback requires explicitly setting `AllowUnprotectedTokenCacheFallback`.

The Extensions sample selects browser session storage in its development configuration, alongside the authentication section:

```json
{
  "KeyValueStorageConfiguration": {
    "BrowserCacheLocation": "SessionStorage"
  }
}
```

`SessionStorage` survives reloads for the tab's session. `LocalStorage`, the framework default, also survives browser restarts; `MemoryStorage` keeps state only for the current page lifetime. This setting controls the host's default key-value store, including both Uno's tokens and the serialized MSAL cache. Browser storage is accessible to scripts on the same origin, and the MSAL cache includes refresh tokens.

## Platform Gotchas

Older Uno builds deployed no-op MSAL helpers to Skia-rendered mobile and WebAssembly apps. The fix, [uno#24055][uno-pr], merged August 13, 2026, corrects which platform assembly is deployed. The sample pins an Uno build containing that fix; the Extensions provider applies the Uno helpers for you.

On **WebAssembly**, allow the sign-in popup and check your hosting headers. Uno's popup flow needs to read the returned popup URL; a restrictive `Cross-Origin-Opener-Policy` can sever that connection. The callback must remain on the app's origin.

On **iOS**, verify that the URL scheme and keychain entitlements reached the signed app. If edits appear to have no effect, clean and rebuild the iOS output. This sample uses the app-delegate lifecycle; apps adopting UIScene should forward callback URLs from the scene delegate instead.

On **Desktop (Skia)**, closing the browser does not notify MSAL's loopback listener. The current Extensions provider cancels an unfinished interactive sign-in after five minutes by default; `InteractiveTimeout` configures that limit.

## Putting It Together

`AuthenticationMsal` gives you token acquisition and persistence through Uno.Extensions' authentication services. Your app supplies the Entra registration and platform callbacks, then uses `IAuthenticationService` for the sign-in lifecycle and `ITokenCache` when it needs the access token.

I introduced the same authentication service in my [Uno Chefs login walkthrough]({% post_url 2025-07-02-chefs-login %}) with a custom provider. MSAL plugs into that pipeline too.

Start with the [Extensions setup guide][extensions-setup], run the sample, and copy its displayed redirect URI into Entra. Come find me in the [Uno Discord][uno-discord] if you get stuck.

For further reading, [Authentication.MsalDemo][gh-msaldemo] demonstrates implementing MSAL authentication **without Uno.Extensions**, using MSAL.NET and Uno's platform helpers directly. Its [setup guide][manual-setup] walks through that approach.
{: .notice--info}

Catch you in the next one :wave:

## Additional Resources

- [Authentication.MsalExtensionsDemo sample (Uno.Extensions)][gh-msalext]
- [Uno.Extensions MSAL Authentication how-to][msal-howto]
- [MSAL provider implementation on Uno.Extensions main][msal-source]

[gh-msaldemo]: https://github.com/unoplatform/Uno.Samples/tree/master/UI/Authentication.MsalDemo
[gh-msalext]: https://github.com/unoplatform/Uno.Samples/tree/master/UI/Authentication.MsalExtensionsDemo
[manual-setup]: https://github.com/unoplatform/Uno.Samples/blob/master/UI/Authentication.MsalDemo/MSAL-SETUP.md
[extensions-setup]: https://github.com/unoplatform/Uno.Samples/blob/master/UI/Authentication.MsalExtensionsDemo/README.md
[entra]: https://entra.microsoft.com/
[uno-discord]: https://platform.uno/discord
[msal-howto]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Authentication/HowTo-MsalAuthentication.html
[msal-source]: https://github.com/unoplatform/uno.extensions/blob/main/src/Uno.Extensions.Authentication.MSAL/MsalAuthenticationProvider.cs
[uno-pr]: https://github.com/unoplatform/uno/pull/24055
[public-client-flows]: https://learn.microsoft.com/troubleshoot/entra/entra-id/app-integration/confidential-client-application-authentication-error-aadsts7000218#how-microsoft-entra-id-determines-the-client-type
[redirect-rules]: https://learn.microsoft.com/entra/identity-platform/reply-url#localhost-exceptions
{% include links.md %}
