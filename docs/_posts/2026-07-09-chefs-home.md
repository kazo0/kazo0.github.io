---
title: "Uno Chefs Walkthrough - Home Page"
category: uno-general
header:
  teaser: /assets/images/chefs-intro/chefslogo.png
  og_image: /assets/images/chefs-intro/chefslogo.png
tags: [uno, unochefs, uno.chefs, uno-chefs, chefs, mvux, feedview, uno-platform]
---

Let's continue our walkthrough of [Uno Chefs][gh-chefs], our flagship reference app for building cross-platform apps with Uno. Last time we covered the [Login Page]({% post_url 2025-07-02-chefs-login %}), and I promised that this time we'd get into the real meat of the application: the Home Page. This is the screen you land on right after a successful login, and it's where Chefs really starts to show off.

There's a lot going on here, so I want to split it into two parts. First, the app shell that wraps the whole logged-in experience. Then, the Home content itself and the MVUX that feeds it.

## One Landing, Two Pages

Here's something that tripped me up the first time I read through the code. When the `LoginModel` finishes authenticating, it navigates to `MainModel`, not `HomeModel`. And if you go looking for `MainModel`, you'll find this:

```csharp
public partial record MainModel;
```

That's the whole thing. An empty record. So what's it for?

`MainPage` is the app shell. It's the persistent frame that holds the bottom navigation and hosts whichever tab you're currently looking at. The Home Page, the Search Page, and the Favorites Page all live *inside* that shell as swappable content. The shell doesn't need any state of its own, which is why `MainModel` is empty. Its job is navigation, and that's handled entirely in XAML.

## The App Shell and Responsive Navigation

Let's look at the interesting parts of `MainPage.xaml`. I've trimmed it down to the essentials, but you can find the full file in the [Chefs repository][gh-chefs-main].

```xml
<Grid uen:Region.Attached="True">
    <!-- ...row and column definitions... -->

    <Grid Grid.Row="0"
          Grid.Column="1"
          uen:Region.Attached="True"
          x:Name="RootGrid"
          uen:Region.Navigator="Visibility" />

    <utu:TabBar Grid.Row="1"
                Grid.Column="1"
                Visibility="{utu:Responsive Normal=Visible, Wide=Collapsed}"
                uen:Region.Attached="True"
                Style="{StaticResource BottomTabBarStyle}">
        <utu:TabBarItem uen:Region.Name="Home" Content="Home">
            <utu:TabBarItem.Icon>
                <PathIcon Data="{StaticResource Icon_Home}" />
            </utu:TabBarItem.Icon>
        </utu:TabBarItem>
        <utu:TabBarItem uen:Region.Name="-/Search" Content="Search" />
        <utu:TabBarItem uen:Region.Name="FavoriteRecipes" Content="Favorites" />
    </utu:TabBar>

    <!-- A second, vertical TabBar for Wide layouts lives here -->
</Grid>
```

A few things are working together here. The `RootGrid` is a navigation region, and setting `uen:Region.Navigator="Visibility"` tells Uno Extensions Navigation to swap the visible child by toggling `Visibility` rather than tearing down and rebuilding views. That keeps tab switches snappy and preserves the state of each tab as you move between them.

The [`TabBar`][gh-chefs-main] from Uno Toolkit is the navigation surface. Each `TabBarItem` is wired to a region by name (`Home`, `-/Search`, `FavoriteRecipes`), so tapping a tab tells the region which view to show. If the `TabBar` looks familiar, that's because we covered it in an early [Toolkit Tuesday post]({% post_url 2023-11-28-toolkit-tuesday-tabbar %}).

Now for my favorite part. Take a look at that `Visibility` binding:

```xml
Visibility="{utu:Responsive Normal=Visible, Wide=Collapsed}"
```

Chefs actually declares TWO tab bars. A horizontal one pinned to the bottom of the screen for narrow layouts like phones, and a vertical one docked to the side for wide layouts like desktop and tablet. The `Responsive` markup extension flips between them based on the window width, so you get a bottom bar on your phone and a proper side rail on a big screen without a single line of code-behind. We dug into the `Responsive` extension in [its own Toolkit Tuesday]({% post_url 2024-01-30-toolkit-tuesday-responsive %}) if you want the full story.

## The Home Content

With the shell out of the way, let's get to the page everyone actually sees. The Home Page is a vertically scrolling list of horizontal carousels: Trending Now, Categories, Recently Added, and Popular Contributors. Each one is its own independently loaded strip of cards.

Here's the `HomeModel` that drives all of it. This time the model is decidedly not empty ([full file here][gh-chefs-homemodel]):

```csharp
public partial record HomeModel
{
    public HomeModel(INavigator navigator, IRecipeService recipe, IUserService userService, IMessenger messenger)
    {
        // ...assign injected services...
    }

    public IListState<Recipe> TrendingNow => ListState
        .Async(this, _recipeService.GetTrending)
        .Observe(_messenger, r => r.Id);

    public IListFeed<CategoryWithCount> Categories => ListFeed.Async(_recipeService.GetCategoriesWithCount);

    public IListFeed<Recipe> RecentlyAdded => ListFeed.Async(_recipeService.GetRecent);

    public IListFeed<User> PopularCreators => ListFeed.Async(_userService.GetPopularCreators);

    // ...navigation commands...
}
```

Four data sources, each a single expressive line. Notice that three of them are `IListFeed<T>` and one is `IListState<T>`. That difference matters, and we'll come back to it.

For now, the takeaway is that a feed is a read-only, asynchronously loaded stream of data. `ListFeed.Async(...)` takes an async method (in this case, service calls like `GetRecent`) and hands back something the UI can bind to. No manual loading flags, no try/catch scattered through the view, no `INotifyPropertyChanged` boilerplate. If you want the deeper background on feeds and states, the [MVUX overview][uno-mvux] is the place to start.

### Binding With the FeedView

So how does the XAML consume these feeds? Through the [`FeedView`][feedview-docs] control from Uno Extensions Reactive. Here's the Trending Now section, trimmed to the important bits ([full page here][gh-chefs-home]):

```xml
<uer:FeedView x:Name="TrendingNowFeed"
              Source="{Binding TrendingNow}">
    <DataTemplate>
        <ScrollViewer HorizontalScrollMode="Auto"
                      VerticalScrollMode="Disabled">
            <muxc:ItemsRepeater ItemsSource="{Binding Data}"
                                uen:Navigation.Request="RecipeDetails"
                                uen:Navigation.Data="{Binding Data}"
                                ItemTemplate="{StaticResource HomeLargeItemTemplate}">
                <muxc:ItemsRepeater.Layout>
                    <muxc:StackLayout Orientation="Horizontal" Spacing="8" />
                </muxc:ItemsRepeater.Layout>
            </muxc:ItemsRepeater>
        </ScrollViewer>
    </DataTemplate>
</uer:FeedView>
```

The `FeedView` is one of the main ways to consume feeds and states in MVUX. As the [docs][feedview-docs] put it, it uses different visual states to control what's displayed depending on the state of the underlying feed. In plain terms, it shows a loading indicator while the data is being fetched, an error template if something goes wrong, and your data template once it arrives. All of that "is it loading, did it fail, is it empty" logic that you'd normally hand-roll comes for free.

Inside the data template, `{Binding Data}` gives us the actual list, and an `ItemsRepeater` with a horizontal `StackLayout` lays the recipe cards out side by side inside a horizontal `ScrollViewer`. That's the whole carousel. The cards themselves are Toolkit `CardContentControl`s, and the whole page leans on `AutoLayout` for spacing, which is a pattern you'll recognize if you followed along with the Login Page.

### Keeping Favorites in Sync

Now back to that `IListState<Recipe>` for Trending Now. Why is it a state when the others are feeds?

Every recipe card has a heart-shaped `ToggleButton` for favoriting. Because a recipe can show up in more than one place across the app (Trending Now, Search results, the Favorites tab), we need a favorite toggled in one spot to be reflected everywhere else. That's a job for a mutable, observable state rather than a read-only feed.

The magic is in that fluent `Observe` call:

```csharp
public IListState<Recipe> TrendingNow => ListState
    .Async(this, _recipeService.GetTrending)
    .Observe(_messenger, r => r.Id);
```

The `Observe` extension subscribes the list state to entity-change messages flowing through an `IMessenger` (Chefs uses the one from the MVVM Toolkit). When a recipe is created, updated, or deleted anywhere in the app, an `EntityMessage<Recipe>` goes out, and `Observe` uses the key selector (`r => r.Id`) to find the matching recipe in the list and apply the change. Favorite a recipe on the details page and the heart on the Home Page updates itself, no manual refresh required. It's a genuinely slick pattern, and it's covered in detail in the [MVUX messaging docs][mvux-messaging-docs].

### Favoriting From the Card

The `ToggleButton` inside the card template is worth a quick look, because binding a command from deep inside a nested template is one of those things that's annoying in vanilla XAML:

```xml
<ToggleButton IsChecked="{Binding IsFavorite}"
              Command="{utu:AncestorBinding AncestorType=uer:FeedView,
                        Path=DataContext.FavoriteRecipe}"
              CommandParameter="{Binding}" />
```

The item's `DataContext` is a single `Recipe`, but the `FavoriteRecipe` command lives on the `HomeModel`. The `AncestorBinding` markup extension from Uno Toolkit walks up the visual tree to the `FeedView` and binds to its `DataContext.FavoriteRecipe`, passing the current recipe as the parameter. No naming elements, no relative-source gymnastics.

## Navigating Out

The Home Page is also a launchpad for the rest of the app, and almost all of it is declarative. Tapping a recipe card fires `uen:Navigation.Request="RecipeDetails"` and passes the bound recipe along as `uen:Navigation.Data`. The profile and notification buttons in the `NavigationBar` use `uen:Navigation.Request="!Profile"` and `!Notifications`, where the `!` prefix opens those views as dialogs. The "View all" buttons route over to the Search page with a pre-built filter. There's very little code behind any of this, which is exactly the point.

## Conclusion

The Home Page packs in a lot: a responsive shell that reshapes its navigation for phone and desktop, four independently loaded data strips driven by MVUX feeds, automatic loading and error handling from the `FeedView`, and a messenger-backed state that keeps favorites in sync across the entire app. And the amount of code-behind to make it all happen is close to zero.

If you want to poke at the real thing, clone the [Uno Chefs repository][gh-chefs] and run it yourself. Reading the code alongside the running app is easily the best way to see how these pieces fit together.

Next time I'd like to dig into the Recipe Details page, where a lot of this navigation and data flow pays off. Until then, hope you learned something, and I'll catch you in the next one :wave:

## Additional Resources

- [Uno Chefs GitHub Repository][gh-chefs]
- [The FeedView Control][feedview-docs]
- [MVUX Messaging][mvux-messaging-docs]
- [Uno Chefs Recipe Book][recipe-book-overview]

[gh-chefs]: https://github.com/unoplatform/uno.chefs
[gh-chefs-main]: https://github.com/unoplatform/uno.chefs/blob/873fae67cef3d12fb55b69c6f3fcebcc0f0101f9/Chefs/Views/MainPage.xaml
[gh-chefs-home]: https://github.com/unoplatform/uno.chefs/blob/873fae67cef3d12fb55b69c6f3fcebcc0f0101f9/Chefs/Views/HomePage.xaml
[gh-chefs-homemodel]: https://github.com/unoplatform/uno.chefs/blob/873fae67cef3d12fb55b69c6f3fcebcc0f0101f9/Chefs/Presentation/HomeModel.cs
[feedview-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/FeedView.html
[mvux-messaging-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Advanced/Messaging.html
[recipe-book-overview]: https://platform.uno/docs/articles/external/uno.chefs/doc/RecipeBooksOverview.html
{% include links.md %}
