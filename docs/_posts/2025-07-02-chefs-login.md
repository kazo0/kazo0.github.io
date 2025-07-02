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

We are also using the `InputExtensions` set of Attached Properties from Uno Toolkit in order to facilitate keyboard navigation support for tabbing through the input controls and invoking the Login command on Enter key press. Once again, we have a couple of Uno Tech Bite videos specifically on this topic :)

{% include video id="ehQYrTtircY" provider="youtube" %}

{% include video id="j0MWpLja3u4" provider="youtube" %}

## The XAML

We can take a look now at the XAML for the Login Page. I extracted a snippet of the most relevant parts, but you can find the full XAML in the [Uno Chefs repository][gh-chefs-login].

```xml
<utu:AutoLayout Spacing="32"
                MaxWidth="500"
                PrimaryAxisAlignment="Center"
                Padding="32">
    <Image utu:AutoLayout.CounterAlignment="Center"
            Width="160"
            Height="90"
            Source="{ThemeResource ChefsLogoWithIcon}"
            Stretch="Uniform" />
    <utu:AutoLayout Spacing="16"
                    PrimaryAxisAlignment="Center">
        <TextBox PlaceholderText="Username"
                  x:Name="LoginUsername"
                  AutomationProperties.AutomationId="LoginUsername"
                  Style="{StaticResource ChefsPrimaryTextBoxStyle}"
                  utu:InputExtensions.ReturnType="Next"
                  utu:InputExtensions.AutoFocusNextElement="{Binding ElementName=LoginPassword}"
                  IsSpellCheckEnabled="False"
                  Text="{Binding UserCredentials.Username, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}">
            <ut:ControlExtensions.Icon>
                <PathIcon Data="{StaticResource Icon_Person_Outline}" />
            </ut:ControlExtensions.Icon>
        </TextBox>
        <PasswordBox x:Name="LoginPassword"
                      AutomationProperties.AutomationId="LoginPassword"
                      utu:InputExtensions.ReturnType="Done"
                      utu:CommandExtensions.Command="{Binding Login}"
                      Password="{Binding UserCredentials.Password, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}"
                      PlaceholderText="Password"
                      Style="{StaticResource OutlinedPasswordBoxStyle}"
                      BorderBrush="{ThemeResource OutlineVariantBrush}">
            <ut:ControlExtensions.Icon>
                <PathIcon Data="{StaticResource Icon_Lock}" />
            </ut:ControlExtensions.Icon>
        </PasswordBox>
        <utu:AutoLayout Spacing="24"
                        Orientation="Horizontal"
                        CounterAxisAlignment="Center"
                        Justify="SpaceBetween"
                        PrimaryAxisAlignment="Stretch">
            <CheckBox Content="Remember me"
                      utu:AutoLayout.PrimaryAlignment="Auto"
                      IsChecked="{Binding UserCredentials.SaveCredentials, Mode=TwoWay}" />
            <Button Content="Forgot password?"
                    Style="{StaticResource TextButtonStyle}" />
        </utu:AutoLayout>
        <Button Content="Login"
                x:Name="LoginButton"
                AutomationProperties.AutomationId="LoginButton"
                Style="{StaticResource ChefsPrimaryButtonStyle}"
                Command="{Binding Login}" />
    </utu:AutoLayout>

    <utu:Divider Style="{StaticResource DividerStyle}" />

    <utu:AutoLayout Spacing="8"
                    PrimaryAxisAlignment="Center">
        <Button Content="Sign in with Apple"
                Command="{Binding LoginWithApple}"
                Style="{StaticResource ChefsTonalButtonStyle}">
            <ut:ControlExtensions.Icon>
                <FontIcon Style="{StaticResource FontAwesomeBrandsFontIconStyle}"
                          Glyph="{StaticResource Icon_Apple_Brand}"
                          FontSize="18"
                          Foreground="{ThemeResource OnSurfaceBrush}" />
            </ut:ControlExtensions.Icon>
        </Button>
        <Button Content="Sign in with Google"
                Command="{Binding LoginWithGoogle}"
                Style="{StaticResource ChefsTonalButtonStyle}">
            <ut:ControlExtensions.Icon>
                <FontIcon Style="{StaticResource FontAwesomeBrandsFontIconStyle}"
                          Glyph="{StaticResource Icon_Google_Brand}"
                          FontSize="18"
                          Foreground="{ThemeResource OnSurfaceBrush}" />
            </ut:ControlExtensions.Icon>
        </Button>
    </utu:AutoLayout>
    <utu:AutoLayout PrimaryAxisAlignment="Center"
                    CounterAxisAlignment="Center"
                    Orientation="Horizontal"
                    Spacing="4">
        <TextBlock Text="Not a member?"
                    Foreground="{ThemeResource OnSurfaceBrush}"
                    Style="{StaticResource LabelLarge}" />
        <Button Content="Register Now"
                uen:Navigation.Request="-/Register"
                Style="{StaticResource TextButtonStyle}" />
    </utu:AutoLayout>
</utu:AutoLayout>
```

First thing we want to look at are the `ControlExtensions.Icon` usages. In the snippet above, check out lines 20-22 and 32-34. This is where we are setting the leading icons for the `TextBox` and `PasswordBox` controls. We are using the `PathIcon` to define the icon shape, which is a vector graphic that scales nicely across different screen sizes and resolutions.

```xml
<!-- Username Icon -->
<ut:ControlExtensions.Icon>
    <PathIcon Data="{StaticResource Icon_Person_Outline}" />
</ut:ControlExtensions.Icon>

<!-- Password Icon -->
<ut:ControlExtensions.Icon>
    <PathIcon Data="{StaticResource Icon_Lock}" />
</ut:ControlExtensions.Icon>
```

Next, we have the `InputExtensions` Attached Properties. This is where we are defining the keyboard navigation behavior. There are actually two properties we are using here: `ReturnType` and `AutoFocusNextElement`.

```xml
<TextBox ...
         utu:InputExtensions.ReturnType="Next"
         utu:InputExtensions.AutoFocusNextElement="{Binding ElementName=LoginPassword}" />
<PasswordBox x:Name="LoginPassword"
             ...
             utu:InputExtensions.ReturnType="Done" />
```

The `ReturnType` property is set to `Next` for the `TextBox`. Which means that when the software keyboard is displayed while the Username `TextBox` is focused, the Next button will be shown in the spot for the Return key. For the `PasswordBox`, we set the `ReturnType` to `Done`, which should show a Done button instead.

The `AutoFocusNextElement` property is set to the `LoginPassword` element. Which means that when the Next button or the Tab key is pressed, the focus will automatically move to the `PasswordBox`.

Finally, we have the `CommandExtensions.Command` Attached Property on the `PasswordBox`. This is where we are binding the `Login` command to the `PasswordBox`. This means that when the Done button is pressed on the software keyboard, it will invoke the `Login` command and it will auto-dismiss the software keyboard.

```xml
<PasswordBox ...
             utu:CommandExtensions.Command="{Binding Login}" />
```

Take note in the video below of the Return key changing from Next to Done as we navigate between the two input controls. As well as the Login successfully occurring when the Done button is pressed on the software keyboard.

<video class="align-center width-half" autoplay loop controls>
  <source src="/assets/images/chefs-login/ios-login.mp4" type="video/mp4" />
</video>

## The MVUX Model

Next, let's take a look at the MVUX model for the Login Page. The Login Page is a bit more complex than the Welcome Page, so we have a few more properties and commands to look at.

```csharp
public partial record LoginModel(IDispatcher Dispatcher, INavigator Navigator, IAuthenticationService Authentication)
{
    public IState<Credentials> UserCredentials => State<Credentials>.Value(this, () => new Credentials());

    public ICommand Login => Command.Create(b => b.Given(UserCredentials).When(CanLogin).Then(DoLogin));

    private bool CanLogin(Credentials userCredentials)
    {
        return userCredentials is not null &&
               !string.IsNullOrWhiteSpace(userCredentials.Username) &&
               !string.IsNullOrWhiteSpace(userCredentials.Password);
    }

    private async ValueTask DoLogin(Credentials userCredentials, CancellationToken ct)
    {
        await Authentication.LoginAsync(Dispatcher, new Dictionary<string, string> { { "Username", userCredentials.Username! }, { "Password", userCredentials.Password! } });
        await NavigateToMain(ct);
    }

    ...

    private async ValueTask NavigateToMain(CancellationToken ct)
        => await Navigator.NavigateViewModelAsync<MainModel>(this, qualifier: Qualifiers.ClearBackStack, cancellation: ct);
}
```

### `UserCredentials` State

First thing's first, we have the `UserCredentials` property. This is a simple `Credentials` object that holds the Username and Password values. We are using an `IState<Credentials>` here instead of an `IFeed<Credentials>` since we want to be able to update the observable property as the user types in the input fields and react to the changes accordingly.

### Login Command

The `Login` command is defined using the `Command.Create` builder method from MVUX. This allows us to build an `ICommand` in a fluent way. We cover this in the Command Builder Chefs Recipe Book article [here][recipe-book-command-builder]. You'll notice the `When(CanLogin)` method that will properly write up the `CanExecute` logic for the `ICommand`. This will ensure that the Login button is only enabled when both the Username and Password fields are not empty, or whatever validation logic you want to implement.

### `IAuthenticationService` Usage

We can see that the `DoLogin` method is where we are using the injected `IAuthenticationService` to handle the authentication logic. If you search the solution for something implementing the `IAuthenticationService` interface, you'll find that it is not implemented in Chefs. Instead, it is registered by the `UseAuthentication` extension method as part of the `IHostBuilder` in the `App.xaml` code-behind logic. This is all made available to us through the [Uno Extensions Authentication][auth-docs] package.

Here is the relevant code snippet from the `App` code-behind:

```csharp
...

.Configure(host => host
    .UseAuthentication(auth =>
        auth.AddCustom(
            custom =>
            {
                custom.Login(async (sp, dispatcher, credentials, cancellationToken) => await ProcessCredentials(credentials));
            },
            name: "CustomAuth")
    )

...

private async ValueTask<IDictionary<string, string>?> ProcessCredentials(IDictionary<string, string> credentials)
{
    // Check for username to simulate credential processing
    if (!(credentials?.TryGetValue("Username", out var username) ??
            false && !string.IsNullOrEmpty(username)))
    {
        return null;
    }

    // Simulate successful authentication by creating a dummy token dictionary
    var tokenDictionary = new Dictionary<string, string>
    {
        { TokenCacheExtensions.AccessTokenKey, "SampleToken" },
        { TokenCacheExtensions.RefreshTokenKey, "RefreshToken" },
        { "Expiry", DateTime.Now.AddMinutes(5).ToString("g") } // Set token expiry
    };

    return tokenDictionary;
}
```

In our case, we are simulating a successful login as long as the Username is not empty. We are achieving this by using the `AddCustom` method on the `IAuthenticationBuilder` to register a `CustomAuthenticationProvider`. The `CustomAuthenticationProvider` provides a basic implementation of the `IAuthenticationProvider` that requires callback methods to be defined for performing login, refresh, and logout actions.
This is where you would typically implement your own authentication logic, such as calling an API to validate the credentials. You can easily swap this out with something like `.AddMsal` or `AddOidc`.

Now, when we call the `LoginAsync` method on the `IAuthenticationService` inside of the `LoginModel`, it will automatically call into the `ProcessCredentials` method to handle the auth request.

## Next Steps

In the next article, we'll get into the real meat of the application and explore the Home Page. In the meantime, I encourage you to check out the [Uno Chefs Recipe Book][recipe-book-overview] and the [Uno Chefs GitHub repository][gh-chefs] and explore the code for yourself. There are a lot of interesting patterns and techniques used throughout the app that you can learn from.

Hope you learned something and I'll catch you in the next one :wave:

## Additional Resources

- [Uno Chefs GitHub Repository][gh-chefs]
- [InputExtensions Focus Recipe Book][recipe-book-input-focus]
- [InputExtensions Return Type Recipe Book][recipe-book-input-returntype]
- [CommandExtensions Recipe Book][recipe-book-command-extensions]

[gh-chefs]: https://github.com/unoplatform/uno.chefs
[controlextensions-docs]: https://platform.uno/docs/articles/external/uno.themes/doc/themes-control-extensions.html
[gh-chefs-login]: https://github.com/unoplatform/uno.chefs/blob/31a9e7621260f69d1b8d9ae845635d9424c45689/Chefs/Views/LoginPage.xaml
[recipe-book-command-builder]: https://platform.uno/docs/articles/external/uno.chefs/doc/extensions/CommandBuilder.html
[auth-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Overview/Authentication/AuthenticationOverview.html
[recipe-book-input-focus]: https://platform.uno/docs/articles/external/uno.chefs/doc/toolkit/InputExtensions.Focus.html
[recipe-book-input-returntype]: https://platform.uno/docs/articles/external/uno.chefs/doc/toolkit/InputExtensions.ReturnType.html
[recipe-book-command-extensions]: https://platform.uno/docs/articles/external/uno.chefs/doc/toolkit/CommandExtensions.html
[recipe-book-overview]: https://platform.uno/docs/articles/external/uno.chefs/doc/RecipeBooksOverview.html
{% include links.md %}
