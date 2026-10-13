---
title: "Uno Chefs Walkthrough - Recipe Details Page"
category: uno-general
header:
  teaser: /assets/images/chefs-intro/chefslogo.png
  og_image: /assets/images/chefs-intro/chefslogo.png
tags: [uno, unochefs, uno.chefs, uno-chefs, chefs, mvux, feedview, navigation, uno-platform]
---

Let's keep our walkthrough of [Uno Chefs][gh-chefs] going. Last time we covered the [Home Page]({% post_url 2026-07-09-chefs-home %}), and at the end of that post I said the Recipe Details page was where a lot of the navigation and data flow we'd set up would finally pay off. This is that post.

This is the screen you land on after tapping one of those recipe cards on the Home Page. It's easily the busiest page in the whole app, so there's a lot to talk about: how the tapped recipe gets here in the first place, a `NavigationBar` with real commands hanging off it, a hero image that completely rearranges itself between phone and desktop, an in-page set of tabs that reuses the exact same navigation trick as the app shell, and a handful of `FeedView`s that should look very familiar by now.

Let's start with a question I kept asking myself the first time I read this page: how does the recipe I tapped actually get *into* the details page?

## Following the Recipe In

Back on the Home Page, tapping a recipe card did this:

```xml
<muxc:ItemsRepeater ItemsSource="{Binding Data}"
                    uen:Navigation.Request="RecipeDetails"
                    uen:Navigation.Data="{Binding Data}"
                    ItemTemplate="{StaticResource HomeLargeItemTemplate}" />
```

`Navigation.Request="RecipeDetails"` names the route we want, and `Navigation.Data` hands the bound `Recipe` along for the ride. That's the whole call site. No `Frame.Navigate`, no manually stuffing the recipe into a parameter bag. So where does that `Recipe` end up?

Take a look at the `RecipeDetailsModel` constructor ([full file here][gh-chefs-detailsmodel]):

```csharp
public partial record RecipeDetailsModel
{
    public RecipeDetailsModel(
        Recipe recipe,
        INavigator navigator,
        IRecipeService recipeService,
        IUserService userService,
        IMessenger messenger,
        IShareService shareService)
    {
        // ...assign injected services...
        Recipe = recipe;
    }

    public Recipe Recipe { get; }

    // ...
}
```

That first `Recipe recipe` parameter is the recipe you tapped. Uno Extensions Navigation resolved it and passed it straight into the constructor alongside all the injected services. The wiring that makes this work lives in the app's route registration ([App.xaml.host.cs][gh-chefs-host]):

```csharp
new ViewMap<RecipeDetailsPage, RecipeDetailsModel>(Data: new DataMap<Recipe>()),
// ...
new RouteMap("RecipeDetails", View: views.FindByViewModel<RecipeDetailsModel>()),
```

The `RouteMap` connects the `"RecipeDetails"` name to the model, and the `DataMap<Recipe>` on the `ViewMap` tells Navigation that this route expects a `Recipe` as its data and knows how to feed it into the model. This is the payoff I was teasing on the Home Page: a card in a list, one `Navigation.Request`, and a strongly-typed `Recipe` shows up as a constructor argument on the other side. If you want the full story on how these maps work, the [Chefs navigation docs][chefs-nav-docs] are a great read.

## Anatomy of the Recipe Details Page

Here's everything on the page, working top to bottom on the wide layout:

1. `NavigationBar` with the recipe name, Share, and Favorite commands
2. Hero image with the author
3. Info card (cook time, difficulty, calories)
4. In-page `TabBar` (Ingredients, Steps, Reviews, Nutrition)
5. Tab content region
6. "Start Cooking!" floating button

<!-- TODO: annotated screenshot of the wide Recipe Details layout with numbered callouts 1-6 matching the list above, saved to /assets/images/chefs-recipe-details/details-anatomy.png -->

We'll work top to bottom: the `NavigationBar` and its commands, the responsive hero, the in-page tabs, and finally the button that kicks off cooking.

## The Model, at a Glance

Before we get into the XAML, let's look at what's driving it. The `RecipeDetailsModel` is a nice tour of almost every MVUX building block we've talked about so far:

```csharp
public Recipe Recipe { get; }

public IState<bool> IsFavorited => State.Value(this, () => Recipe.IsFavorite);

public IState<User> User => State
    .Async(this, async ct => await _userService.GetById(Recipe.UserId, ct))
    .Observe(_messenger, u => u.Id);

public IListFeed<Ingredient> Ingredients =>
    ListFeed.Async(async ct => await _recipeService.GetIngredients(Recipe.Id, ct));

public IListFeed<Step> Steps =>
    ListFeed.Async(async ct => await _recipeService.GetSteps(Recipe.Id, ct));

public IListState<Review> Reviews => ListState
    .Async(this, async ct => await _recipeService.GetReviews(Recipe.Id, ct))
    .Observe(_messenger, r => r.Id);
```

There's a nice mix here, and the choice of type is doing real work in each case:

1. `Recipe` is just a plain property. We already have the whole recipe from navigation, so there's nothing async to load.
2. `Ingredients` and `Steps` are `IListFeed<T>`. They're read-only lists pulled from a service, and we want the loading behavior for free. Feeds are the right call.
3. `IsFavorited`, `User`, and `Reviews` are states. We need to *mutate* the favorite flag, and both `User` and `Reviews` are `Observe`d against the `IMessenger` so a change made elsewhere in the app shows up here without a manual refresh. That's the same messenger-backed pattern we used to keep favorites in sync on the Home Page.

If the feed-versus-state distinction is still fuzzy, the MVUX docs have a nice [rule of thumb for when to reach for each][mvux-feed-vs-state]. The short version: read-only list from a service, use a feed; need to edit it or react to outside changes, use a state.

## The NavigationBar and Its Commands

The top of the page is a Toolkit `NavigationBar` whose title binds straight to the recipe name, with two `AppBarButton`s hanging off its `PrimaryCommands`:

```xml
<utu:NavigationBar Content="{Binding Recipe.Name}">
    <utu:NavigationBar.PrimaryCommands>
        <AppBarButton Command="{Binding Share}">
            <AppBarButton.Icon>
                <PathIcon Data="{StaticResource Icon_Share}" />
            </AppBarButton.Icon>
        </AppBarButton>
        <AppBarButton Command="{Binding Favorite}">
            <AppBarButton.Icon>
                <PathIcon Data="{Binding IsFavorited,
                          Converter={StaticResource BoolToHeartIconConverter},
                          FallbackValue={StaticResource Icon_Heart},
                          TargetNullValue={StaticResource Icon_Heart}}" />
            </AppBarButton.Icon>
        </AppBarButton>
    </utu:NavigationBar.PrimaryCommands>
</utu:NavigationBar>
```

The `NavigationBar` is Toolkit's cross-platform take on a top app bar, and we covered it all the way back in [its own Toolkit Tuesday]({% post_url 2023-11-21-toolkit-tuesday-navigationbar %}) if you want the deep dive.

The Favorite button is the fun one. Its icon is bound to `IsFavorited` through a `BoolToObjectConverter`:

```xml
<converters:BoolToObjectConverter x:Key="BoolToHeartIconConverter"
                                  TrueValue="{StaticResource Icon_Heart_Filled}"
                                  FalseValue="{StaticResource Icon_Heart}" />
```

So when `IsFavorited` is `true` we get a filled heart, and when it's `false` we get the outline. The `Favorite` command is what flips it:

```csharp
public async ValueTask Favorite(CancellationToken ct)
{
    await _recipeService.Favorite(Recipe, ct);
    await IsFavorited.UpdateAsync(s => !s);
}
```

It persists the change through the service and then calls `IsFavorited.UpdateAsync` to toggle the state, which the icon binding picks up immediately. And because favoriting also publishes an entity message under the hood, that heart we watched update on the Home Page? This is the page that fires the change it reacts to. The loop closes.

The `Share` command uses an injected `IShareService` to hand the recipe (and its steps) off to the native share sheet via the Windows `DataTransfer` APIs, which Uno maps onto each platform's share experience:

```csharp
public async Task Share(CancellationToken ct)
{
    await _shareService.ShareRecipe(Recipe, await Steps, ct);
}
```

Notice the `await Steps` in there. Because `Steps` is a feed, you can `await` it directly to grab its current value when you need the raw data rather than a UI binding. Handy.

## A Hero Image That Rearranges Itself

Here's where the page shows off. On a wide screen, the recipe photo sits on the left with a little vertical info card floating over its bottom-left corner. On a phone, that same photo becomes a full-width banner with the info card turned into a horizontal strip laid across it. Same data, completely different arrangement, and it's all driven by the `Responsive` markup extension we dug into in [its Toolkit Tuesday]({% post_url 2024-01-30-toolkit-tuesday-responsive %}).

The image itself swaps presentation based on width:

```xml
<!-- Wide: image fills its column -->
<Image Visibility="{utu:Responsive Normal=Collapsed, Wide=Visible}"
       Source="{Binding Recipe.ImageUrl}"
       Stretch="UniformToFill"
       utu:AutoLayout.PrimaryAlignment="Stretch" />

<!-- Narrow: image is a fixed-height banner -->
<Border Visibility="{utu:Responsive Normal=Visible, Wide=Collapsed}"
        Height="300">
    <Image Source="{Binding Recipe.ImageUrl}" Stretch="UniformToFill" />
</Border>
```

And the info card that overlays it uses `AutoLayout.IsIndependentLayout` so it can float on top of the image rather than pushing it around, with its orientation, size, and margin all flipping through `Responsive`:

```xml
<utu:AutoLayout utu:AutoLayout.IsIndependentLayout="True"
                Margin="{utu:Responsive Normal='16,263,16,0', Wide='14,14,0,0'}"
                Orientation="{utu:Responsive Normal=Horizontal, Wide=Vertical}"
                Width="{utu:Responsive Normal=358, Wide=98}"
                Height="{utu:Responsive Normal=74, Wide=317}">
    <!-- cook time, difficulty, and calories chips -->
</utu:AutoLayout>
```

That `IsIndependentLayout` attached property is worth remembering. It pulls an element out of the normal `AutoLayout` flow so it can be positioned freely, which is exactly what you want for an overlay like this. The same trick shows up again at the bottom of the page for the floating action button.

<!-- TODO: side-by-side screenshot of the hero image + info card in wide vs narrow layouts -->

## Nested Navigation: The In-Page Tabs

This is my favorite part of the page, because it's the same idea as the app shell from the Home Page post, just nested one level deeper.

The middle of the page has four tabs: Ingredients, Steps, Reviews, and Nutrition. Tapping one swaps the content below without any code-behind. If that sounds familiar, it should, it's the exact same region-plus-`Visibility`-navigator pattern the app shell used to switch between Home, Search, and Favorites. Except here it's happening *inside* a single page that is itself already hosted inside the shell.

Here's the structure, trimmed down:

```xml
<utu:AutoLayout uen:Region.Attached="True">
    <utu:TabBar uen:Region.Attached="True"
                Style="{StaticResource TopTabBarStyle}">
        <utu:TabBarItem uen:Region.Name="IngredientsTab" Content="Ingredients" IsSelected="True" />
        <utu:TabBarItem uen:Region.Name="StepsTab" Content="Steps" />
        <utu:TabBarItem uen:Region.Name="ReviewsTab" Content="Reviews" />
        <utu:TabBarItem uen:Region.Name="NutritionTab" Content="Nutrition" />
    </utu:TabBar>

    <ScrollViewer>
        <Grid x:Name="TabNavGrid"
              uen:Region.Attached="True"
              uen:Region.Navigator="Visibility">
            <utu:AutoLayout uen:Region.Name="IngredientsTab"> <!-- ... --> </utu:AutoLayout>
            <utu:AutoLayout uen:Region.Name="StepsTab" Visibility="Collapsed"> <!-- ... --> </utu:AutoLayout>
            <utu:AutoLayout uen:Region.Name="ReviewsTab" Visibility="Collapsed"> <!-- ... --> </utu:AutoLayout>
            <Grid uen:Region.Name="NutritionTab" Visibility="Collapsed"> <!-- ... --> </Grid>
        </Grid>
    </ScrollViewer>
</utu:AutoLayout>
```

Each `TabBarItem` carries a `Region.Name` that matches the `Region.Name` of a content block inside the `TabNavGrid`. The grid is marked with `Region.Navigator="Visibility"`, so selecting a tab simply toggles which child is visible instead of tearing views down and rebuilding them. The tab content stays alive as you flip between tabs, which keeps things fast and preserves scroll position.

The only real difference from the shell is the `TabBar` style: the shell used `BottomTabBarStyle`, and here we use `TopTabBarStyle` to get the classic horizontal tab strip. Same navigation engine, different chrome. The [Chefs navigation shell docs][chefs-nav-shell] walk through this region-based approach in more detail.

## FeedViews, Again (and an Empty State)

Each of the first three tabs hosts a `FeedView` bound to one of the model's feeds, and they follow the exact pattern we established on the Home Page: a `FeedView` wrapping an `ItemsRepeater`, with `{Binding Data}` giving you the loaded list. Here's the Ingredients tab, trimmed to the essentials:

```xml
<uer:FeedView Source="{Binding Ingredients}">
    <DataTemplate>
        <muxc:ItemsRepeater ItemsSource="{Binding Data}">
            <muxc:ItemsRepeater.Layout>
                <muxc:StackLayout Orientation="Vertical" Spacing="2" />
            </muxc:ItemsRepeater.Layout>
            <muxc:ItemsRepeater.ItemTemplate>
                <!-- ingredient row: name on the left, quantity on the right -->
            </muxc:ItemsRepeater.ItemTemplate>
        </muxc:ItemsRepeater>
    </DataTemplate>
</uer:FeedView>
```

Steps works the same way. Reviews adds one detail I really like, and it's a `FeedView` feature we mentioned but didn't get to use on the Home Page: the empty state.

```xml
<uer:FeedView x:Name="ReviewsFeed"
              NoneTemplate="{StaticResource EmptyTemplate}"
              Source="{Binding Reviews}">
    <DataTemplate>
        <!-- ...reviews list... -->
    </DataTemplate>
</uer:FeedView>
```

That `NoneTemplate` is what the `FeedView` shows when the feed successfully loads but comes back empty. Instead of a blank tab, a recipe with no reviews yet gets a friendly "No Reviews Yet" graphic:

```xml
<DataTemplate x:Key="EmptyTemplate">
    <utu:AutoLayout PrimaryAxisAlignment="Center" Spacing="24">
        <BitmapIcon Width="72" Height="72" UriSource="{ThemeResource Empty_Recipe}" />
        <TextBlock Style="{StaticResource TitleLarge}"
                   Text="No Reviews Yet"
                   TextAlignment="Center" />
    </utu:AutoLayout>
</DataTemplate>
```

This is one of those things the `FeedView` just hands you. Loading indicator, error template, empty state, and data template, all as first-class visual states of the same control. You write the templates; it decides which one to show.

<!-- TODO: screenshot of the Reviews tab showing the "No Reviews Yet" empty state -->

### Liking a Review

The review cards each have thumbs-up and thumbs-down `ToggleButton`s, and they lean on two patterns we've already met plus one new one. First, the command binding uses `AncestorBinding` to reach back up to the `Like` and `Dislike` commands on the model, exactly like the favorite heart did on the Home Page:

```xml
<ToggleButton Command="{utu:AncestorBinding AncestorType=uer:FeedView, Path=DataContext.Like}"
              CommandParameter="{Binding}"
              IsChecked="{Binding UserLike, Converter={StaticResource UserLikeCheckedConverter}, Mode=TwoWay}">
    <ToggleButton.Content>
        <!-- outline thumb + like count -->
    </ToggleButton.Content>
    <ut:ControlExtensions.AlternateContent>
        <!-- filled thumb + like count -->
    </ut:ControlExtensions.AlternateContent>
</ToggleButton>
```

The new piece is `ControlExtensions.AlternateContent` from Uno Themes. It lets a `ToggleButton` show one piece of content when it's unchecked (`Content`) and a different one when it's checked (`AlternateContent`), which is how the thumb icon fills in when you tap it, no converter or code-behind required. It's a small thing, but it's exactly the kind of quality-of-life helper the Themes library is full of.

## The Nutrition Chart

The fourth tab is a little different from the other three. Instead of a `FeedView` over a list, it's a donut chart of the recipe's carbs, protein, and fat, rendered with [LiveCharts][livecharts]:

```xml
<ctrl:ChartControl DataContext="{Binding Recipe}"
                   CarbBrush="{ThemeResource NutritionCarbsValBrush}"
                   ProteinBrush="{ThemeResource NutritionProteinValBrush}"
                   FatBrush="{ThemeResource NutritionFatValBrush}" />
```

LiveCharts renders through SkiaSharp, which means the exact same chart draws identically on every target Uno runs on. I won't go deep on the charting here, it's really a topic of its own, but it's a good reminder that the wider .NET ecosystem of SkiaSharp-based libraries just works inside an Uno app.

<!-- TODO: screenshot of the Nutrition tab donut chart -->

## Start Cooking

The last thing on the page is that floating "Start Cooking!" button pinned to the bottom-right corner. It's a normal `Button` with `AutoLayout.IsIndependentLayout="True"` so it floats over the scrolling content, and its command hops over to the live cooking experience:

```csharp
public async ValueTask LiveCooking(IImmutableList<Step> steps) =>
    await _navigator.NavigateRouteAsync(this, "LiveCooking",
        data: new LiveCookingParameter(Recipe, steps));
```

This one's a route navigation rather than the declarative `Navigation.Request` we saw earlier, because we're building up a `LiveCookingParameter` to carry both the recipe and its steps. Same navigation engine, just invoked from code when we need to assemble the payload ourselves.

## Conclusion

The Recipe Details page really is where the groundwork from the earlier posts pays off. The recipe you tapped arrived as a plain constructor argument thanks to a `DataMap`. The `NavigationBar` commands persist a favorite and fire the very message the Home Page listens for. The hero image reshapes itself for phone and desktop with nothing but `Responsive` markup. The in-page tabs reuse the shell's region navigation one level deeper. And four `FeedView`s handle loading, empty, and data states across ingredients, steps, and reviews without a single `IsBusy` flag in sight.

Next time I want to follow that "Start Cooking!" button into the Live Cooking page, where the app walks you through a recipe step by step. Until then, clone the [Uno Chefs repository][gh-chefs] and poke at this page with the app running next to the code. It's the best way to watch these pieces click together.

Hope you learned something and I'll catch you in the next one :wave:

## Additional Resources

- [Uno Chefs GitHub Repository][gh-chefs]
- [Recipe Details Page source][gh-chefs-detailspage]
- [MVUX: feeds vs states][mvux-feed-vs-state]
- [Uno Chefs Recipe Book][recipe-book-overview]

[gh-chefs]: https://github.com/unoplatform/uno.chefs
[gh-chefs-detailspage]: https://github.com/unoplatform/uno.chefs/blob/873fae67cef3d12fb55b69c6f3fcebcc0f0101f9/Chefs/Views/RecipeDetailsPage.xaml
[gh-chefs-detailsmodel]: https://github.com/unoplatform/uno.chefs/blob/873fae67cef3d12fb55b69c6f3fcebcc0f0101f9/Chefs/Presentation/RecipeDetailsModel.cs
[gh-chefs-host]: https://github.com/unoplatform/uno.chefs/blob/873fae67cef3d12fb55b69c6f3fcebcc0f0101f9/Chefs/App.xaml.host.cs
[chefs-nav-docs]: https://platform.uno/docs/articles/external/uno.chefs/doc/toolkit/NavigateTabBar.html
[chefs-nav-shell]: https://platform.uno/docs/articles/external/uno.chefs/doc/toolkit/NavigationShell.html
[mvux-feed-vs-state]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Walkthrough/ListFeed.howto.html
[recipe-book-overview]: https://platform.uno/docs/articles/external/uno.chefs/doc/RecipeBooksOverview.html
[livecharts]: https://livecharts.dev/
{% include links.md %}
