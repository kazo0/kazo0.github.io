---
title: "Uno Chefs Walkthrough - Home Page"
category: uno-general
header:
  teaser: /assets/images/chefs-home/hero.png
  og_image: /assets/images/chefs-home/hero.png
tags: [uno, unochefs, uno.chefs, uno-chefs, chefs, mvux, feedview, uno-platform]
---

Welcome back to our walkthrough of [Uno Chefs][gh-chefs], our flagship reference implementation for building cross-platform apps with .NET. Last time we [logged in]({% post_url 2025-07-02-chefs-login %}), and I promised we'd finally get into the real meat of the application. So let's do it. The Home Page is where Chefs starts to feel like a real app, and it's the perfect place to talk about the thing that powers most of the screens you'll see from here on out: MVUX and the `FeedView`.

## Anatomy of the Home Page

The Home Page is essentially a vertical stack of horizontally-scrolling carousels. Each carousel is its own little world of data, loaded independently, and you can swipe through recipes, categories, and creators without ever leaving the page.

<figure>
    <a href="/assets/images/chefs-home/chefs-home.png"><img src="/assets/images/chefs-home/chefs-home.png" alt="Home Page Anatomy"/></a>
    <figcaption>
        <ol>
            <li>NavigationBar with profile and notification actions</li>
            <li>Trending Now carousel</li>
            <li>Categories carousel</li>
            <li>Recently Added carousel</li>
            <li>Popular Contributors carousel</li>
        </ol>
    </figcaption>
</figure>

<!-- TODO: screenshot of the full Home Page (wide layout) annotated with the 5 numbered regions above -> save to /assets/images/chefs-home/chefs-home.png -->

Four of these five regions are backed by the exact same pattern, so once you understand one, you understand them all. That pattern is the [`FeedView`][feedview-docs].

## The Star of the Show: FeedView

If there's one control to take away from this article, it's the `FeedView` from Uno Extensions' Reactive UI namespace (`Uno.Extensions.Reactive.UI`). Every carousel on this page is driven by one.

Here's the thing about loading data in a real app: it's never instant. You have a loading state, a success state, an error state, and sometimes an empty state. Wiring all of that up by hand for every list on every page gets old fast. The `FeedView` handles those states for you out of the box, based directly on an MVUX feed exposed from your model.

Take a look at the Trending Now section, trimmed down to the essentials:

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
                    <muxc:StackLayout Orientation="Horizontal"
                                      Spacing="8" />
                </muxc:ItemsRepeater.Layout>
            </muxc:ItemsRepeater>
        </ScrollViewer>
    </DataTemplate>
</uer:FeedView>
```

A few things worth pointing out:

1. The `Source` binds to a `TrendingNow` property on the model. No code-behind, no manual `IsLoading` flags.
2. Inside the `DataTemplate`, the successfully-loaded value is available as `Data`. That's why the `ItemsRepeater` binds its `ItemsSource` to `{Binding Data}`.
3. We use a WinUI `ItemsRepeater` with a horizontal `StackLayout` to get that swipeable, carousel-style row of cards.

The `FeedView` also exposes `Refresh`, error content, and progress content that you can template if you want to customize any of those states. For this page we lean on the sensible defaults and keep the XAML lean.

## Cards With CardContentControl

Each recipe in the carousel is rendered inside a [`CardContentControl`][card-docs] from the Uno Toolkit. You might be tempted to reach for a `Border` with a `CornerRadius` and a shadow, but `CardContentControl` gives you proper elevation, theming, and interaction states that match Material out of the box.

```xml
<utu:CardContentControl Width="328"
                        CornerRadius="4"
                        Style="{StaticResource FilledCardContentControlStyle}">
    <utu:AutoLayout Background="{ThemeResource SurfaceBrush}">
        <Border Height="144">
            <Image Source="{Binding ImageUrl}"
                   Stretch="UniformToFill" />
        </Border>
        <!-- title, calories, and the favorite toggle live here -->
    </utu:AutoLayout>
</utu:CardContentControl>
```

You'll also notice the ever-present [`AutoLayout`][autolayout-docs] doing the heavy lifting for the internal arrangement, just like it did on the Login Page. It's basically a Figma AutoLayout frame brought to life in XAML, and Chefs uses it everywhere.

### The Favorite Toggle

Tucked into the corner of each large recipe card is a heart-shaped `ToggleButton`. Two details here are worth calling out.

First, toggling the favorite state needs to invoke a command that lives on the *model*, not on the individual recipe item. Since the button is deep inside a `DataTemplate`, we reach back up the visual tree to the `FeedView`'s `DataContext` using the Toolkit's `AncestorBinding` markup extension:

```xml
<ToggleButton Style="{StaticResource IconToggleButtonStyle}"
              IsChecked="{Binding IsFavorite}"
              Command="{utu:AncestorBinding AncestorType=uer:FeedView,
                                            Path=DataContext.FavoriteRecipe}"
              CommandParameter="{Binding}">
    <ToggleButton.Content>
        <PathIcon Data="{StaticResource Icon_Heart}" />
    </ToggleButton.Content>
    <ut:ControlExtensions.AlternateContent>
        <PathIcon Data="{StaticResource Icon_Heart_Filled}" />
    </ut:ControlExtensions.AlternateContent>
</ToggleButton>
```

Second, the empty and filled heart states are handled declaratively via the `ControlExtensions.AlternateContent` attached property from Uno Themes. When the toggle is checked, the alternate (filled) content is shown. No converters, no code-behind swapping icons.

## Responsive Contributors

The Popular Contributors carousel throws in one more nice touch: the creator cards rearrange themselves based on the available width using the Toolkit's `Responsive` markup extension.

```xml
<utu:AutoLayout Orientation="{utu:Responsive Normal=Vertical, Wide=Horizontal}">
    <PersonPicture Width="96"
                   Height="96"
                   ProfilePicture="{Binding UrlProfileImage}" />
    <!-- name + recipe count -->
</utu:AutoLayout>
```

On narrow layouts the profile picture stacks on top of the name; on wide layouts they sit side by side. One attribute, zero visual states to manage. I covered the `Responsive` extension in more depth back in [this Toolkit Tuesday][tt-responsive] if you want the full story.

## Navigating Away

You'll have spotted the `uen:Navigation.Request` and `uen:Navigation.Data` attached properties sprinkled throughout the XAML. These come from Uno Extensions' Navigation and let you wire up navigation declaratively, right on the control that triggers it.

Tapping a recipe in a carousel navigates to `RecipeDetails` and passes the tapped recipe along as data:

```xml
<muxc:ItemsRepeater ItemsSource="{Binding Data}"
                    uen:Navigation.Request="RecipeDetails"
                    uen:Navigation.Data="{Binding Data}" />
```

The NavigationBar's profile and notification buttons do the same thing with `!Profile` and `!Notifications` requests (the `!` prefix tells the navigator to show these as dialogs/flyouts rather than a forward page navigation). More complex navigations, like the "View all" buttons, route through commands on the model instead.

## The Model Layer

Now let's flip over to the `HomeModel` and see where all these feeds come from. This is where MVUX really shines: the whole page's data is described in a handful of declarative properties.

```csharp
public partial record HomeModel
{
    public IListState<Recipe> TrendingNow => ListState
        .Async(this, _recipeService.GetTrending)
        .Observe(_messenger, r => r.Id);

    public IListFeed<CategoryWithCount> Categories =>
        ListFeed.Async(_recipeService.GetCategoriesWithCount);

    public IListFeed<Recipe> RecentlyAdded =>
        ListFeed.Async(_recipeService.GetRecent);

    public IListFeed<User> PopularCreators =>
        ListFeed.Async(_userService.GetPopularCreators);

    public async ValueTask FavoriteRecipe(Recipe recipe, CancellationToken ct) =>
        await _recipeService.Favorite(recipe, ct);
}
```

Each carousel is a single line. `ListFeed.Async` takes a service method that returns an `IImmutableList<T>` and wraps it in a feed that the `FeedView` knows how to render, complete with the loading and error handling I mentioned earlier.

Notice that three of the four are `IListFeed` (read-only, load-once streams) while `TrendingNow` is an `IListState`. Why the difference? Because Trending Now has that favorite toggle, and we want it to stay in sync.

### Keeping Favorites in Sync

Here's my favorite part of this page (pun fully intended). When you tap the heart on a trending recipe, we don't want to blow away the whole carousel and re-fetch. We just want *that one card* to flip its state. This is exactly what the `.Observe` operator is for:

```csharp
public IListState<Recipe> TrendingNow => ListState
    .Async(this, _recipeService.GetTrending)
    .Observe(_messenger, r => r.Id);
```

The `Observe` extension hooks the list-state up to the [Community Toolkit `IMessenger`][messaging-docs]. It listens for `EntityMessage<Recipe>` messages and, using the key selector `r => r.Id`, applies updates to the matching item in the list automatically. Update messages patch the item in place; delete messages remove it.

So who sends those messages? The `RecipeService` does, over in the business layer, when you favorite a recipe:

```csharp
public async ValueTask Favorite(Recipe recipe, CancellationToken ct)
{
    var currentUser = await userService.GetCurrent(ct);
    var updatedRecipe = recipe with { IsFavorite = !recipe.IsFavorite };

    await api.Api.Recipe.Favorited.PostAsync(q =>
    {
        q.QueryParameters.RecipeId = updatedRecipe.Id;
        q.QueryParameters.UserId = currentUser.Id;
    }, cancellationToken: ct);

    // ...update the FavoritedRecipes list-state...

    messenger.Send(new EntityMessage<Recipe>(EntityChange.Updated, updatedRecipe));
}
```

Trace the flow: you tap the heart, the `AncestorBinding` fires `FavoriteRecipe` on the model, which calls into `RecipeService.Favorite`, which hits the API and then broadcasts an `EntityMessage<Recipe>`. Because `TrendingNow` is observing the messenger, it picks up that message and updates the matching recipe, no manual refresh required. This same message also keeps the Favorites tab (which we'll get to in a future post) consistent, all without those two screens knowing anything about each other.

That decoupling is the whole point. The business layer doesn't know or care which screens are showing a given recipe. It just announces "this recipe changed," and any state observing the messenger reacts. This is the reactive backbone that makes the rest of Chefs tick.

## The Client Layer

One last stop. Notice that `api.Api.Recipe.Trending.GetAsync(...)` call inside the service. That `api` is a strongly-typed HTTP client generated by [Kiota][kiota] from the Chefs API's OpenAPI definition, wired up through Uno Extensions' HTTP support. You get compile-time-safe endpoints (`Recipe.Trending`, `Recipe.Favorited`, and friends) instead of hand-rolling `HttpClient` calls and string URLs. We'll dig deeper into the client and API layers as the recipes we cover get more data-heavy.

## Next Steps

That's the Home Page! We covered a lot: the `FeedView` and MVUX feeds, `CardContentControl`, `AncestorBinding`, responsive layouts, declarative navigation, and the messenger-driven reactivity that keeps favorites in sync across the app.

Next time we'll follow one of these cards into the Recipe Details page, where things get a good deal more interesting: reviews, steps, ingredients, and a lot more feed composition. In the meantime, go poke around the [Uno Chefs GitHub repository][gh-chefs] and the [Recipe Book][recipe-book-overview], and try wiring up an `.Observe` in one of your own apps.

Hope you learned something and I'll catch you in the next one :wave:

## Additional Resources

- [Uno Chefs GitHub Repository][gh-chefs]
- [Home Page XAML][gh-chefs-home]
- [HomeModel.cs][gh-chefs-homemodel]
- [FeedView documentation][feedview-docs]
- [MVUX + Messenger documentation][messaging-docs]
- [Reactive Messaging Recipe Book][recipe-book-messaging]

[gh-chefs]: https://github.com/unoplatform/uno.chefs
[gh-chefs-home]: https://github.com/unoplatform/uno.chefs/blob/873fae67/Chefs/Views/HomePage.xaml
[gh-chefs-homemodel]: https://github.com/unoplatform/uno.chefs/blob/873fae67/Chefs/Presentation/HomeModel.cs
[feedview-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/FeedView.html
[messaging-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Advanced/Messaging.html
[card-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/CardAndCardContentControl.html
[autolayout-docs]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/controls/AutoLayoutControl.html
[recipe-book-overview]: https://platform.uno/docs/articles/external/uno.chefs/doc/RecipeBooksOverview.html
[recipe-book-messaging]: https://platform.uno/docs/articles/external/uno.chefs/doc/extensions/ReactiveMessaging.html
[tt-responsive]: {% post_url 2024-01-30-toolkit-tuesday-responsive %}
[kiota]: <https://learn.microsoft.com/en-us/openapi/kiota/>
{% include links.md %}
