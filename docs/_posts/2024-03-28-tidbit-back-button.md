---
title: "Uno Tidbit: Handling the System Back Button"
category: uno-tidbit
header:
  teaser: /assets/images/tidbit-hero.png
  og_image: /assets/images/tidbit-hero.png
tags: [uno-tidbits, uno-tidbit, tidbit, backbutton, back-button, uno-platform, uno, unoplatform]
---

Welcome to the first edition of Uno Tidbits! In this series, we will be covering small, bite-sized topics that are useful to know when working with Uno Platform. These will be quick reads that you can consume in a few minutes and will cover a wide range of topics. Today, we are going to cover how to handle the system back button in your Uno Platform app.

{% include video id="YhO-z7WOYhI" provider="youtube" %}

## Platform Specifics

The platforms we are going to focus on today are Android and WASM. These platforms are the most common to have a system back button that is used to navigate backward in the app. On Android, the back button can be either a physical or software button on the device, while on WASM, it is a software button in the browser.

By default, on Android, pressing the system back button will close the app. On WASM, pressing the system back button will navigate back in the browser history. However, you may want to override this behavior to provide a custom experience in your app.

## Using the SystemNavigationManager

Uno Platform provides a cross-platform implementation of the [`SystemNavigationManager` API][systemnavigationmanager-docs] that hooks into the native system back button events.

### BackRequested Event

Hook onto the `BackRequested` event from the `SystemNavigationManager` in order to handle the system back button press. But, be sure to set the `Handled` flag to `true` on the [`BackRequestedEventArgs`][systemnavigationmanager-eventargs-docs] to prevent the default back behavior of the underlying platform.

### AppViewBackButtonVisibility (WASM Specific)

On WASM, for the `BackRequested` event to be raised, you must first set the [`AppViewBackButtonVisibility`][systemnavigationmanager-button-vis-docs] property to `Visible`. We don't want to be hijacking the browser back button by default so this is why this extra step is needed as an explicit opt-in.

### Example

Now, let's bring this all together and get this article wrapped up. This is supposed to be a small tidbit, after all!

Within your `App.cs` file in the `OnLaunched` method, you can add the following code to opt-in to the WASM back button handling:

```csharp
protected override void OnLaunched(LaunchActivatedEventArgs args)
{
    // Code omitted for brevity

#if !WINDOWS
    Windows.UI.Core.SystemNavigationManager.GetForCurrentView().AppViewBackButtonVisibility = Windows.UI.Core.AppViewBackButtonVisibility.Visible;
#endif

    // Code omitted for brevity
}
```

And then, let's say we had an app with two pages. Our `MainPage` navigates to our `SecondPage` and we want to be able to navigate back from the `SecondPage` using the system back button.

In the `SecondPage.xaml.cs` file, you can add the following code to handle the system back button press:

```csharp
public sealed partial class SecondPage : Page
{
    public SecondPage()
    {
        this.InitializeComponent();

        Loaded += OnLoaded;
        Unloaded += OnUnloaded;
    }

    private void OnLoaded(object sender, RoutedEventArgs e)
    {
#if !WINDOWS
        SystemNavigationManager.GetForCurrentView().BackRequested += OnBackRequested;
#endif
    }

     void OnUnloaded(object sender, RoutedEventArgs e)
    {
#if !WINDOWS
        SystemNavigationManager.GetForCurrentView().BackRequested -= OnBackRequested;
#endif	
    }

    private void OnBackRequested(object? sender, BackRequestedEventArgs e)
    {
        Frame.GoBack();

        // Need to set this to true to prevent the device back bubbling up to the system and closing the app
        e.Handled = true;
    }
}
```

Note that the `!WINDOWS` preprocessor directive is used to ensure that the code is only executed on the platforms where the `SystemNavigationManager` API is available. This API is not available on WinAppSDK apps.
{: .notice--warning}

## Conclusion

That's it! We now have an app that can handle the system back button in a cross-platform way without having to write platform-specific code!

You can check out a working example of this in the [BackApp repository][backapp-gh] on GitHub.

Catch you in the next one :wave:

[systemnavigationmanager-docs]: https://learn.microsoft.com/en-us/uwp/api/windows.ui.core.systemnavigationmanager
[systemnavigationmanager-eventargs-docs]: https://learn.microsoft.com/en-us/uwp/api/windows.ui.core.backrequestedeventargs
[systemnavigationmanager-button-vis-docs]: https://learn.microsoft.com/en-us/uwp/api/windows.ui.core.systemnavigationmanager.appviewbackbuttonvisibility
[backapp-gh]: https://github.com/kazo0/BackApp