---
title: "Uno Chefs Walkthrough - Login Page"
category: uno-general
header:
  teaser: /assets/images/chefs-intro/chefslogo.png
  og_image: /assets/images/chefs-intro/chefslogo.png
tags: [uno, unochefs, uno.chefs, uno-chefs, chefs, hot-design, uno-platform]
---

Let's continue our walkthrough of [Uno Chefs][gh-chefs], our new flagship reference implementation when it comes to building cross-platform apps. This time, we'll be covering the Login/Register Pages. These are the next pages after navigating from the Welcome Page, which we covered [last time]({% post_url 2025-05-25-chefs-intro %}).

## Anatomy of the Login Page

I know an article on a login page sounds boring. But, there's actually a lot of good stuff packed into this simple screen.

We don't need to separate the anatomy based on our wide/narrow layouts. This is one of the few pages that we simply lock to a `MaxWidth` so it looks good enough for both layout breakpoints.

<figure>
    <a href="/assets/images/chefs-login/chefs-login.png"><img src="/assets/images/chefs-login/chefs-login.png" alt="Login Page Anatomy"/></a>
    <figcaption>
        <ol>
            <li>Username TextBox</li>
            <li>Password PasswordBox</li>
            <li>Login Button</li>
            <li>Social Login Buttons</li>
            <li>Registration Text Button</li>
        </ol>
    </figcaption>
</figure>

The first, and most important, part of any login experience are the Username/Password fields. Not only should they be clearly indicated, it should be easy to quickly navigate between the two fields and invoke a form submission without using your mouse at all.

### Custom Icons

Along with using the `PlaceholderText` property for the Username `TextBox` and the `PasswordBox` controls, we are using the `ControlExtensions.Icon` Attached Property from Uno Themes to add a nice leading icon image for each control. For more info on the `ControlExtensions.Icon` Attached Property you can check out the related Uno Tech Bite:

{% include video id="y7h9cAsDvfs" provider="youtube" %}

As a quick recap, the `Icon` Attached Property from Uno Themes' [`ControlExtensions`][controlextensions-docs] class provides the ability to define any type of `IconElement` and displays it in many situations as part of the custom styles coming from Uno Themes.

The `ControlExtensions` Attached Properties must be properly referenced inside of the control's `ControlTemplate`. They do not work with the out-of-the-box Fluent styles from the core Uno library.
{: .notice--warning}

### Keyboard Navigation

We are also using the `InputExtensions` set of Attached Properties from Uno Toolkit in order to facilitate keyboard navigation support for tabbing through the input controls and invoking the Login command on Enter key press. Once again, we have an Uno Tech Bite specifically on this topic :)

{% include video id="y7h9cAsDvfs" provider="youtube" %}

## The XAML

Let's dive into the XAML for the Welcome Page and see how it's all wired up. As mentioned above, we have two `FlipView` controls. The first one contains the hero images that are displayed in the wide layout:

```xml
<FlipView IsEnabled="False"
          Visibility="{utu:Responsive Normal=Collapsed, Wide=Visible}"
          utu:AutoLayout.PrimaryAlignment="Stretch"
          SelectedIndex="{Binding Pages.CurrentIndex}">
  <FlipView.Items>
    <!-- First Splash image -->
    <Image Source="ms-appx:///Assets/Welcome/Wide/first_splash_screen.jpg"
           Stretch="UniformToFill" />

    <!-- Second Splash image -->
    <Image Source="ms-appx:///Assets/Welcome/Wide/second_splash_screen.jpg"
           Stretch="UniformToFill" />

    <!-- Third Splash image -->
    <Image Source="ms-appx:///Assets/Welcome/Wide/third_splash_screen.jpg"
           Stretch="UniformToFill" />
  </FlipView.Items>
</FlipView>
```

Take note of the `Visibility` property on the `FlipView`. We only want this `FlipView` to be visible when the window is wide enough.

Our second `FlipView` contains three instances of a small `UserControl` called [`WelcomeView`][welcomeview-xaml]. This `FlipView` is actually always visible. It serves as the main content to the right of the hero image in the wide layout, and as the main content in the narrow (normal) layout.

```xml
<FlipView x:Name="flipView"
          utu:AutoLayout.PrimaryAlignment="Stretch"
          Background="Transparent"
          utu:SelectorExtensions.PipsPager="{Binding ElementName=pipsPager}"
          SelectedIndex="{Binding Pages.CurrentIndex, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}">
  <FlipView.Items>
    <ctrl:WelcomeView ImageUrl="ms-appx:///Assets/Welcome/first_splash_screen.png"
                      Title="Welcome to your App!"
                      VerticalContentAlignment="Bottom"
                      Description="Embark on a delightful coding journey as you discover, create, and share awesome script tailored to your app and project preferences." />
    <ctrl:WelcomeView ImageUrl="ms-appx:///Assets/Welcome/second_splash_screen.png"
                      VerticalContentAlignment="Bottom"
                      Title="Explore Thousands of Recipes"
                      Description="Find your next culinary adventure or last minute lunch from our vast collection of diverse and mouth-watering recipes." />
    <ctrl:WelcomeView ImageUrl="ms-appx:///Assets/Welcome/third_splash_screen.png"
                      Title="Personalize Your Recipe Journey"
                      VerticalContentAlignment="Bottom"
                      Description="Create your own recipe collections, cookbooks, follow other foodies, and share your creations with the Chefs community." />
  </FlipView.Items>
</FlipView>
```

You may have noticed an extra property set on this `FlipView`. The [`SelectorExtensions.PipsPager`][selector-ext-docs] attached property from Uno Toolkit allows you to connect anything deriving from `Selector` (which is the case for `FlipView`) and keep its `SelectedIndex` in sync with a `PipsPager`.

The last pieces of the puzzle are the navigation buttons. We are using the [`FlipViewExtensions`][flipview-ext-docs] from Uno Toolkit to accomplish this. Given the following XAML, we can move the `FlipView` to the next or previous item, if possible:

```xml
<!-- Some code has been omitted for brevity -->

<Button Content="Previous"
        utu:FlipViewExtensions.Previous="{Binding ElementName=flipView}">

<Button Content="Next"
        utu:FlipViewExtensions.Next="{Binding ElementName=flipView}"/>
```

Putting it all together, we now have multiple ways to navigate through the `FlipView` items. The user can swipe left or right, click the navigation buttons, or use the `PipsPager` to jump to a specific item.

<a href="/assets/images/chefs-intro/welcome-mobile.gif">
  <img class="align-center width-half" src="/assets/images/chefs-intro/welcome-mobile.gif" alt="Welcome Page Flip"/>
</a>

Only thing left now is to properly show/hide the Next and Previous buttons depending on the current index of the `FlipView`.

## The MVUX Model

We could probably achieve this logic in the XAML itself, maybe using something like a Converter. But this way is more fun. Let's take a look at the entirety of our `WelcomeModel`:

```csharp
public partial record WelcomeModel()
{
  public IState<IntIterator> Pages => State<IntIterator>.Value(this, () => new IntIterator(Enumerable.Range(0, 3).ToImmutableList()));
}
```

That's it?!?

Yes, that's it! We are using MVUX as a presentation framework. MVUX is part of the Uno Extensions family and is designed around the notion of exposing immutable and observable streams data that are compatible with Data Binding. I highly recommend you check out the [MVUX documentation][mvux-docs] for more details on how it works.

The [`IntIterator`][int-iterator] is a simple immutable `record` defined in Chefs that keeps track of the current index within a list of items. In this case, we are using it to keep track of the current index of the `FlipView` items. The `Enumerable.Range(0, 3)` creates a list of integers from 0 to 2, which corresponds to the three items in our `FlipView`.

We are exposing the `IntIterator` as an `IState`, an observable stream of data that can also store state. Meaning the `IState` can be updated from the View via two-way bindings. This allows us to two-way bind the `SelectedIndex` of the `FlipView` to the `Pages.CurrentIndex`, which is the current index of the `IntIterator`. You can see where we are doing this [here][welcome-pages-binding]. We are also observing the `CanMoveNext` and `CanMovePrevious` properties of the `IntIterator` to determine whether we should show or hide the [Next and Previous buttons][nav-buttons-xaml].

## Next Steps

In the next article, we will move forward past the Welcome Page and dive into the Login Page and beyond. In the meantime, I encourage you to check out the [Uno Chefs GitHub repository][gh-chefs] and explore the code for yourself. There are a lot of interesting patterns and techniques used throughout the app that you can learn from.

Hope you learned something and I'll catch you in the next one :wave:

[release-webinar]: https://www.youtube.com/live/xV8kIfqhuuA?si=hW4IyliKjTpJr82C
[release-blog]: https://platform.uno/blog/uno-platform-studio-6-0/
[nick-blog]: https://nicksnettravelswp.builttoroam.com/uno-platform-6-0/
[gh-chefs]: https://github.com/unoplatform/uno.chefs
[yt-tech-bites]: https://www.youtube.com/playlist?list=PLl_OlDcUya9rP_fDcFrHWV3DuP7KhQKRA
[docs-recipe-book]: https://aka.platform.uno/chefs-recipebooks
[docs-chefs]: https://aka.platform.uno/chefs-sampleapp
[welcomeview-xaml]: https://github.com/unoplatform/uno.chefs/blob/2b5ad5cc8459e4db3565640f3a1ec808e164be8c/Chefs/Views/Controls/WelcomeView.xaml
[selector-ext-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/Selector-extensions.html
[flipview-ext-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/FlipView-extensions.html
[mvux-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Overview.html
[int-iterator]: https://github.com/unoplatform/uno.chefs/blob/2b5ad5cc8459e4db3565640f3a1ec808e164be8c/Chefs/Business/Models/Iterator.cs#L29-L36
[welcome-pages-binding]: https://github.com/unoplatform/uno.chefs/blob/2b5ad5cc8459e4db3565640f3a1ec808e164be8c/Chefs/Views/WelcomePage.xaml#L50
[nav-buttons-xaml]: https://github.com/unoplatform/uno.chefs/blob/2b5ad5cc8459e4db3565640f3a1ec808e164be8c/Chefs/Views/WelcomePage.xaml#L85-L98
[controlextensions-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/themes-control-extensions.html
{% include links.md %}
