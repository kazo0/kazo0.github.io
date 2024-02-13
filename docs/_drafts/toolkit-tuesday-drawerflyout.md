---
title: "Toolkit Tuesdays: DrawerFlyoutPresenter"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, drawerflyout, drawer, drawerflyoutpresenter, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][toolkit-homepage] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-homepage]. I hope you find them useful too!

This week we are covering the `DrawerFlyoutPresenter`, a lightweight way to create a [drawer-like experience][m3-drawer-guidelines] in your applications using [Flyouts][winui-flyout]. It can also be utilized for other experiences such as a [bottom sheet][m3-bottom-sheet] or a [side sheet][m3-side-sheet]. In this article, we will cover both the "navigation drawer" and "bottom sheet" use cases.

The `DrawerFlyoutPresenter` is a special `ContentPresenter` to be used in the template of a [`FlyoutPresenter`][winui-flyoutpresenter] to enable gesture support.

## Anatomy of a `DrawerFlyoutPresenter`

### Android

![Android Nav Flyout Anatomy](/assets/images/drawerflyout/android-nav-anatomy.png){: .align-center .width-half}

### WASM

![WASM Nav Flyout Anatomy](/assets/images/drawerflyout/wasm-nav-anatomy.png){: .align-center}

1. Flyout Content
2. Light Dismiss Layer

## Properties

| Property                        | Type                       | Description                                                                                                                              |
|---------------------------------|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| `OpenDirection`                 | `DrawerOpenDirection`=`Up` | Gets or sets the direction in which the drawer opens toward.<br/>note: The position of drawer when opened is the opposite of this value. |
| `DrawerLength`                  | `GridLength`=`0.66*`       | Get or sets the length (width or height depending on the `OpenDirection`) of the drawer.                                                 |
| `LightDismissOverlayBackground` | `Brush`                    | Gets or sets the brush used to paint the light dismiss overlay. The default value is `#80808080` (from the default style).               |
| `IsGestureEnabled`              | `bool`=`true`              | Get or sets a value that indicates whether the user can interact with the control using gesture.                                         |
| `IsLightDismissEnabled`         | `bool`=`true`              | Gets or sets a value that indicates whether the drawer flyout can be light-dismissed.                                                    |

All properties can be used both as a dependency property or as an attached property, much like the `ScrollViewer` properties
{: .notice--info}

## Styles

The Uno Toolkit provides a set of pre-built styles that can be used as the `FlyoutPresenterStyle` of a `Flyout` to create a `DrawerFlyoutPresenter` experience. These styles are:

- `LeftDrawerFlyoutPresenterStyle` (OpenDirection=Right)
- `TopDrawerFlyoutPresenterStyle` (OpenDirection=Down)
- `RightDrawerFlyoutPresenterStyle` (OpenDirection=Left)
- `BottomDrawerFlyoutPresenterStyle` (OpenDirection=Up)

These styles set the `OpenDirection` property of the `DrawerFlyoutPresenter` to the appropriate value and set the `DrawerLength` to `0.66*` (66% of the screen width/height). They also set some defaults for the `LightDismissOverlayBackground`. You can also use these styles as a base to create your own custom styles, which is what we will be doing later on in this article!

## Usage

Let's start by creating a simple `Flyout` that will open with the click of a `Button` and a `Grid` to display the content of the `Flyout`.

```xml
<Grid>
    <Button HorizontalAlignment="Center"
            VerticalAlignment="Center" 
            Content="Open Flyout">
        <Button.Flyout>
            <Flyout Placement="Full">
                <Grid Background="CornflowerBlue" 
                        Margin="50">
                    <TextBlock VerticalAlignment="Center"
                                HorizontalAlignment="Center"
                                Text="This is a flyout" />
                </Grid>
            </Flyout>
        </Button.Flyout>
    </Button>
</Grid>
```

![Simple Android Flyout](/assets/images/drawerflyout/android-simple-flyout.gif){: .width-half}

Breathtaking.

What if we want to anchor the `Flyout` to the edge of the screen?

What if we want to be able to drag the `Flyout` using a gesture?

What if we want to be able to control the size of the flyout relative to its content?

This is where the Uno Toolkit comes to the rescue. The Toolkit provides a specialized `FlyoutPresenter` called the `DrawerFlyouterPresenter` that can be used to customize the way your `Flyout` content behaves.

[`FlyoutPresenter`][winui-flyoutpresenter]s are used as a means to style the content of a Flyout. You typically don't need to use them directly. Instead, you would normally set the [`FlyoutPresenterStyle`][winui-flyoutpresenterstyle] property on the `Flyout` to a custom `Style` whose `TargetType` is set to `FlyoutPresenter`. For example, say we wanted the original example's `Flyout` to have some nice rounded corners and we can also move the `Margin` and `Background` properties to the `FlyoutPresenterStyle`:

```xml
<Button HorizontalAlignment="Center"
        VerticalAlignment="Center" 
        Content="Open Flyout">
    <Button.Flyout>
        <Flyout Placement="Full">
            <Flyout.FlyoutPresenterStyle>
                <Style TargetType="FlyoutPresenter">
                    <Setter Property="Background" Value="CornflowerBlue" />
                    <Setter Property="Margin" Value="50" />
                    <Setter Property="CornerRadius" Value="20" />
                </Style>
            </Flyout.FlyoutPresenterStyle>
            <Grid>
                <TextBlock VerticalAlignment="Center"
                           HorizontalAlignment="Center"
                           Text="This is a flyout" />
            </Grid>
        </Flyout>
    </Button.Flyout>
</Button>
```

![Simple Android Flyout with FlyoutPresenterStyle](/assets/images/drawerflyout/android-simple-flyout-style.png){: .width-half}

Now that we have a better understanding of how `FlyoutPresenter` works, let's take a look at what you can do with the `DrawerFlyoutPresenter` from the Uno Toolkit!

So, let's build that Navigation Drawer experience that was shown earlier on in the [Anatomy section](#anatomy-of-a-drawerflyoutpresenter).

### Navigation Drawer

We can use the `DrawerFlyoutPresenter` to build a navigation drawer experience. Complete with gesture support, light dismiss, and integration with other Uno Toolkit controls.

Here's what we are looking to build by the end of this section (both Android and WASM are shown):

![Android Nav Flyout](/assets/images/drawerflyout/android-nav-drawer.gif){: .width-half}

![WASM Nav Flyout](/assets/images/drawerflyout/wasm-nav-drawer.gif)

You may have noticed that we are opening the navigation drawer by clicking on the `MainCommand` of a `NavigationBar`. This is a custom control from the Uno Toolkit and one that we have [previously covered]({% post_url 2023-11-21-toolkit-tuesday-navigationbar %}).

So, let's add a `NavigationBar` to our `Page` and set the `MainCommandMode` to `Action` so it will always be visible. We will also set the `MainCommand.Icon` to a burger menu icon:

```xml
<Page x:Class="DrawerApp.MainPage"
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:local="using:DrawerApp"
      xmlns:utu="using:Uno.Toolkit.UI"
      Background="{ThemeResource BackgroundBrush}">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>
        <utu:NavigationBar Content="First Page"
                           MainCommandMode="Action">
            <utu:NavigationBar.MainCommand>
                <AppBarButton>
                    <AppBarButton.Icon>
                        <BitmapIcon UriSource="ms-appx:///DrawerApp/Assets/Icons/burger.png" />
                    </AppBarButton.Icon>
                </AppBarButton>
            </utu:NavigationBar.MainCommand>
        </utu:NavigationBar>
    </Grid>
</Page>
```

![Android initial page with NavigationBar](/assets/images/drawerflyout/android-drawer-step-1.png){: .width-half}

Now, we can have the `MainCommand` open a `Flyout` with `Placement="Full"` when clicked. We will add some dummy content to get started:

```diff
 <utu:NavigationBar Content="First Page"
                    MainCommandMode="Action">
     <utu:NavigationBar.MainCommand>
         <AppBarButton>
             <AppBarButton.Icon>
                 <BitmapIcon UriSource="ms-appx:///DrawerApp/Assets/Icons/burger.png" />
             </AppBarButton.Icon>
+           <AppBarButton.Flyout>
+               <Flyout Placement="Full">
+                   <Grid Background="{ThemeResource SurfaceBrush}">
+                       <TextBlock Text="Hello World!"
+                                  HorizontalAlignment="Center"
+                                  VerticalAlignment="Center" />
+                   </Grid>
+               </Flyout>
+           </AppBarButton.Flyout>
         </AppBarButton>
     </utu:NavigationBar.MainCommand>
 </utu:NavigationBar>
```

Setting the `Placement` to `Full` is required to ensure the `Flyout` takes up the entire screen. This is important because the `DrawerFlyoutPresenter` will be anchored to the edge of the screen and will not behave properly if the `Flyout` is not taking up the entire screen.
{: .notice--warning}

![Android page with full Flyout](/assets/images/drawerflyout/android-drawer-step-2.png){: .width-half}

Let's now use one of the [pre-built styles that we covered earlier](#styles) and set the `FlyoutPresenterStyle` to `LeftDrawerFlyoutPresenterStyle`:

```diff
 <utu:NavigationBar Content="First Page"
                    MainCommandMode="Action">
     <utu:NavigationBar.MainCommand>
         <AppBarButton>
             <AppBarButton.Icon>
                 <BitmapIcon UriSource="ms-appx:///DrawerApp/Assets/Icons/burger.png" />
             </AppBarButton.Icon>
             <AppBarButton.Flyout>
                 <Flyout Placement="Full"
+                        FlyoutPresenterStyle="{StaticResource LeftDrawerFlyoutPresenterStyle}">
                     <Grid Background="{ThemeResource SurfaceBrush}">
                         <TextBlock Text="Hello World!"
                                    HorizontalAlignment="Center"
                                    VerticalAlignment="Center" />
                     </Grid>
                 </Flyout>
             </AppBarButton.Flyout>
         </AppBarButton>
     </utu:NavigationBar.MainCommand>
 </utu:NavigationBar>
```

Now when we press on the `MainCommand`, we should have a `Flyout` open from the left side of the screen. We can also drag the `Flyout` to close it:

![Android page with LeftDrawerFlyoutPresenterStyle](/assets/images/drawerflyout/android-drawer-step-3.gif){: .width-half}

Starting to look good!

Next up, let's extract the `Flyout` into a separate XAML file to clean up our `MainPage.xaml`:

`NavFlyout.xaml`:

```xml
<Flyout x:Class="DrawerApp.NavFlyout"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:local="using:DrawerApp"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        mc:Ignorable="d"
        Placement="Full"
        FlyoutPresenterStyle="{StaticResource LeftDrawerFlyoutPresenterStyle}">

    <Grid Background="{ThemeResource SurfaceBrush}">
        <TextBlock Text="Hello World!"
                   HorizontalAlignment="Center"
                   VerticalAlignment="Center" />
    </Grid>
</Flyout>
```

`MainPage.xaml`:

```diff
 <Page x:Class="DrawerApp.MainPage"
       xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
       xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
       xmlns:local="using:DrawerApp"
       xmlns:utu="using:Uno.Toolkit.UI"
       xmlns:um="using:Uno.Material"
       Background="{ThemeResource BackgroundBrush}">
     <Grid>
         <Grid.RowDefinitions>
             <RowDefinition Height="Auto" />
             <RowDefinition Height="*" />
         </Grid.RowDefinitions>
         <utu:NavigationBar Content="First Page"
                            MainCommandMode="Action">
             <utu:NavigationBar.MainCommand>
                 <AppBarButton>
                     <AppBarButton.Icon>
                         <BitmapIcon UriSource="ms-appx:///DrawerApp/Assets/Icons/burger.png" />
                     </AppBarButton.Icon>
                     <AppBarButton.Flyout>
-                       <Flyout Placement="Full"
-                               FlyoutPresenterStyle="{StaticResource LeftDrawerFlyoutPresenterStyle}">
-                           <Grid Background="{ThemeResource SurfaceBrush}">
-                               <TextBlock Text="Hello World!"
-                                          HorizontalAlignment="Center"
-                                          VerticalAlignment="Center" />
-                           </Grid>
-                       </Flyout>
+                        <local:NavFlyout />
                     </AppBarButton.Flyout>
                 </AppBarButton>
             </utu:NavigationBar.MainCommand>
         </utu:NavigationBar>
     </Grid>
 </Page>
```

Let's pause and take a look at what this looks like on another platform, maybe one with a different screen size like browser:

![WASM page with LeftDrawerFlyoutPresenterStyle](/assets/images/drawerflyout/wasm-drawer-step-4.png)

You'll notice that the navigation drawer is much wider in this case. This is because the `DrawerLength` is set to `0.66*` by default. This means that the drawer will take up 66% of the screen width.

Next, let's add some nice navigation-like content to our `NavFlyout`:

```diff
 <Flyout x:Class="DrawerApp.NavFlyout"
         xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
         xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
         xmlns:local="using:DrawerApp"
         xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
         xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
+        xmlns:um="using:Uno.Material"
+        xmlns:utu="using:Uno.Toolkit.UI"
         mc:Ignorable="d"
         Placement="Full"
         FlyoutPresenterStyle="{StaticResource LeftDrawerFlyoutPresenterStyle}">
 
-    <Grid Background="{ThemeResource SurfaceBrush}">
-        <TextBlock Text="Hello World!"
-                   HorizontalAlignment="Center"
-                   VerticalAlignment="Center" />
-    </Grid>
+    <Grid RowSpacing="12"
+          Margin="20,0">
+        <Grid.RowDefinitions>
+            <RowDefinition Height="Auto" />
+            <RowDefinition Height="Auto" />
+            <RowDefinition Height="Auto" />
+            <RowDefinition Height="Auto" />
+        </Grid.RowDefinitions>
+
+        <Image HorizontalAlignment="Center"
+               Height="150"
+               Width="150"
+               Source="ms-appx:///DrawerApp/Assets/Icons/unologo.png"
+               Margin="0,16" />
+
+        <Button Grid.Row="1"
+                FontSize="24"
+                Content="Notifications"
+                Style="{StaticResource TextButtonStyle}"
+                HorizontalContentAlignment="Left"
+                HorizontalAlignment="Stretch">
+            <um:ControlExtensions.Icon>
+                <FontIcon FontWeight="Bold"
+                          FontSize="24"
+                          Glyph="&#xea8f;" />
+            </um:ControlExtensions.Icon>
+        </Button>
+        <utu:Divider Grid.Row="2" />
+        <Button Grid.Row="3"
+                Content="Help"
+                FontSize="24"
+                Style="{StaticResource TextButtonStyle}"
+                HorizontalContentAlignment="Left"
+                HorizontalAlignment="Stretch">
+            <um:ControlExtensions.Icon>
+                <FontIcon FontWeight="Bold"
+                          FontSize="24"
+                          Glyph="&#xE897;" />
+            </um:ControlExtensions.Icon>
+        </Button>
+    </Grid>
 </Flyout>
```

![Android page with LeftDrawerFlyoutPresenterStyle and content](/assets/images/drawerflyout/android-drawer-step-5.png){: .width-half}

Almost there! 

Only difference left are the rounded corners and the shadow. We can add these by creating a custom `Style` for the `FlyoutPresenter` that is based on the `LeftDrawerFlyoutPresenterStyle`. In our `AppResources.xaml`, we can add the following:

```xml
<Style x:Key="NavFlyoutPresenterStyle"
       TargetType="FlyoutPresenter"
       BasedOn="{StaticResource LeftDrawerFlyoutPresenterStyle}">
    <Setter Property="CornerRadius" Value="0,20,20,0" />
</Style>
```

Then, we set the `FlyoutPresenterStyle` on our `Flyout` accordingly:

```diff
 <Flyout x:Class="DrawerApp.NavFlyout"
         ...
-        FlyoutPresenterStyle="{StaticResource LeftDrawerFlyoutPresenterStyle}">
+        FlyoutPresenterStyle="{StaticResource NavFlyoutPresenterStyle}">
         ...
 </Flyout>
```

![Android page with custom NavFlyoutPresenterStyle](/assets/images/drawerflyout/android-drawer-step-6.png){: .width-half}

And there we go! We have a nice navigation drawer experience that is consistent across platforms:

![Android Nav Flyout](/assets/images/drawerflyout/android-nav-drawer.gif){: .width-half}

![WASM Nav Flyout](/assets/images/drawerflyout/wasm-nav-drawer-final.gif)

We can even get spicy and use some of the `DrawerFlyoutPresenter` attached properties to customize the experience further. For example, we can set the `DrawerLength` to `0.9*` to make the drawer take up 90% of the screen width and use a ridiculous `LightDismissOverlayBackground`:

```diff
 <Style x:Key="NavFlyoutPresenterStyle"
        TargetType="FlyoutPresenter"
        BasedOn="{StaticResource LeftDrawerFlyoutPresenterStyle}">
     <Setter Property="CornerRadius" Value="0,20,20,0" />
+    <Setter Property="utu:DrawerFlyoutPresenter.DrawerLength" Value="0.9*" />
+    <Setter Property="utu:DrawerFlyoutPresenter.LightDismissOverlayBackground" Value="Red" />
 </Style>
```

![Android page with Red NavFlyoutPresenterStyle](/assets/images/drawerflyout/android-nav-drawer-red.gif){: .width-half}

Now that we know how to build a beautiful navigation drawer, we can apply these skills to build a [bottom sheet][m3-bottom-sheet] experience!

### Bottom Sheet

Here's what we are looking to build by the end of this section (both Android and WASM are shown):

![Android Bottom Sheet](/assets/images/drawerflyout/android-sheet.gif){: .width-half}

![WASM Bottom Sheet](/assets/images/drawerflyout/wasm-sheet.gif)

![ResponsiveView Resizing](/assets/images/responsive/responsiveView_resize.gif)

You can see here how each template is applied as the screen width changes. But, what if we don't define a template for a certain screen width? Let's remove the `NarrowTemplate` and `WideTemplate` from the above example and see what happens:

```diff
  <utu:ResponsiveView>
      <utu:ResponsiveView.NarrowestTemplate>
          <DataTemplate>
              <Grid Background="Red">
                  <TextBlock TextWrapping="WrapWholeWords"
                            Text="Narrowest Template"
                            FontSize="32" />
              </Grid>
          </DataTemplate>
      </utu:ResponsiveView.NarrowestTemplate>
-        <utu:ResponsiveView.NarrowTemplate>
-            <DataTemplate>
-                <Grid Background="Green">
-                    <TextBlock Text="Narrow Template"
-                               FontSize="32" />
-                </Grid>
-            </DataTemplate>
-        </utu:ResponsiveView.NarrowTemplate>
      <utu:ResponsiveView.NormalTemplate>
          <DataTemplate>
              <Grid Background="Blue">
                  <TextBlock Text="Normal Template"
                            FontSize="32" />
              </Grid>
          </DataTemplate>
      </utu:ResponsiveView.NormalTemplate>
-        <utu:ResponsiveView.WideTemplate>
-            <DataTemplate>
-                <Grid Background="Purple">
-                    <TextBlock Text="Wide Template"
-                               FontSize="32" />
-                </Grid>
-            </DataTemplate>
-        </utu:ResponsiveView.WideTemplate>
      <utu:ResponsiveView.WidestTemplate>
          <DataTemplate>
              <Grid Background="Orange">
                  <TextBlock Text="Widest Template"
                            FontSize="32" />
              </Grid>
          </DataTemplate>
      </utu:ResponsiveView.WidestTemplate>
  </utu:ResponsiveView>
```

![ResponsiveView Resizing without Narrow or Wide Templates](/assets/images/responsive/responsiveView_resize2.gif)

Notice now how we stay in certain templates for longer as the screen width changes. This is because the `ResponsiveView` control will always pick the smallest defined template that satisfies the width requirements. Since we removed the `WideTemplate` and `NarrowTemplate`, the `ResponsiveView` control will default to the `NormalTemplate` and the `NarrowestTemplate` for the `Wide` and `Narrow` screen widths, respectively.

More information on the template resolution logic can be found in the [official documentation][responsive-view-layout-logic-docs]
{: .notice--info}

## Responsive Markup Extension

The `Responsive` markup extension is a new markup extension that is used to help build responsive layouts. It is similar to the `ResponsiveView` control in that it shares the resolution logic for the current window width. However, it is different in that it is not a container control and it does not require the definition of multiple templates. Instead, it enables finer-grained control over the value of a single property on a control based on the current window width.

### Properties

| Property    | Type               | Description                                                |
|-------------|--------------------|------------------------------------------------------------|
| `Narrowest` | `object`           | Value to be used when the screen size is at its narrowest. |
| `Narrow`    | `object`           | Value to be used when the screen size is narrow.           |
| `Normal`    | `object`           | Value to be used when the screen size is normal.           |
| `Wide`      | `object`           | Value to be used when the screen size is wide.             |
| `Widest`    | `object`           | Value to be used when the screen size is at its widest.    |
| `Layout`    | `ResponsiveLayout` | Overrides the screen size thresholds/breakpoints.          |

The `ResponsiveLayout` property is used to override the default screen size threshold/breakpoints. We will cover this in more detail [later](#responsivelayout).
{: .notice--info}

### Usage

Let's take the [previous example](#usage) using `ReponsiveView` and convert it to use the `Responsive` markup extension instead:

```xml
<Page xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:local="using:ResponsiveApp"
      xmlns:utu="using:Uno.Toolkit.UI"
      x:Class="ResponsiveApp.MainPage"
      Background="{ThemeResource ApplicationPageBackgroundThemeBrush}">
    <Grid Background="{utu:Responsive Narrowest=Red, Narrow=Green, Normal=Blue, Wide=Purple, Widest=Orange}">
            <TextBlock TextWrapping="WrapWholeWords"
                       Text="{utu:Responsive Narrowest='Narrowest', Narrow='Narrow', Normal='Normal', Wide='Wide', Widest='Widest'}"
                       FontSize="32" />
    </Grid>
</Page>
```

![Responsive Markup Extension Resizing](/assets/images/responsive/responsiveMarkup_resize.gif)

Much simpler, right? The `Responsive` markup extension is a great way to quickly adapt a single property value based on the current window width. It is also a great way to quickly prototype a responsive layout without having to define multiple templates.

Now, what about if we wanted to customize the threshold values for the screen sizes? You'll notice that for both `ResponsiveView` and the `Responsive` markup extension, we have a property available to us of type `ResponsiveLayout`. This property allows us to override the default screen size threshold/breakpoints in multiple ways.

## ResponsiveLayout

The `ResponsiveView` control has a property called `ResponsiveLayout` and the `Responsive` markup extension has a property called `Layout`. These properties are of type `ResponsiveLayout` and have the following default values:

### Properties

| Property    | Type     | Description            |
|-------------|----------|------------------------|
| `Narrowest` | `double` | Default value is 150.  |
| `Narrow`    | `double` | Default value is 300.  |
| `Normal`    | `double` | Default value is 600.  |
| `Wide`      | `double` | Default value is 800.  |
| `Widest`    | `double` | Default value is 1080. |

The default `ResponsiveLayout` can be overridden from different locations. In the following order of precedence:

1. From the `ResponsiveLayout`/`Layout` property
2. In the property owner's parent `.Resources` with `x:Key="DefaultResponsiveLayout"`, or the property owner's ancestor's `.Resources`
3. In `Application.Resources` with `x:Key="DefaultResponsiveLayout"`

For more information on the `ResponsiveLayout` properties, check out the [official documentation][responsive-view-layout-docs].
{: .notice--info}

#### Examples

Let's take the following `ResponsiveLayout` instance defined in our `Application.Resources`:

```xml
<utu:ResponsiveLayout x:Key="CustomLayout" Narrowest="0" Narrow="0" Normal="0" Wide="100" Widest="1200" />
```

This ridiculous example will cause the responsive resolution logic to stay in `Wide` mode for most configurations until the screen width is at least 1200 pixels wide. Let's see what that looks like:

![ResponsiveView Resizing with Custom ResponsiveLayout](/assets/images/responsive/responsiveView_resize3.gif)

The way you could achieve this would look different depending on whether you are using `ResponsiveView` or the `Responsive` markup extension. Let's take a look at both examples:

##### ResponsiveView

```xml
<utu:ResponsiveView ResponsiveLayout="{StaticResource CustomLayout}">

    ...

</utu:ResponsiveView>
```

##### Responsive Markup Extension

```xml
<Grid Background="{utu:Responsive Layout={StaticResource CustomLayout}, Narrowest=Red, Narrow=Green, Normal=Blue, Wide=Purple, Widest=Orange}">
        <TextBlock TextWrapping="WrapWholeWords"
                    Text="{utu:Responsive Layout={StaticResource CustomLayout}, Narrowest='Narrowest', Narrow='Narrow', Normal='Normal', Wide='Wide', Widest='Widest'}"
                    FontSize="32" />
</Grid>
```

Another approach would be to override the default `ResponsiveLayout` resource using the resource key `DefaultResponsiveLayout`. The beauty of this technique is that you can scope the resource to a specific control, the current page, or the entire application. Let's take a look at an example:

```xml
<Page ...>
    <Page.Resources>
         <utu:ResponsiveLayout x:Key="DefaultResponsiveLayout"
                          Narrow="400"
                          Wide="800" />
    </Page.Resources>
    <utu:ResponsiveView>

        ...

    </utu:ResponsiveView>
</Page>
```

## Conclusion

If you want to take a look at the full source code for the examples above, you can find it on this [GitHub repo][responsive-sample-gh].

I hope you enjoyed this edition of Toolkit Tuesdays! There is even more to learn about `Responsive` so I hope you will continue to explore it on your own.

I encourage you to consult the full documentation for `ResponsiveView` and the `Responsive` markup extension using the links below. I also want to welcome you to contribute to making `Responsive` even better! Whether you have discovered some bugs, want to make improvements, or want to enhance the documentation, please jump into the fun on the [Uno Toolkit GitHub repo][uno-toolkit]!

## Further Reading

- [ResponsiveView Docs][responsiveview-docs]
- [Responsive Markup Extension Docs][responsiveextension-docs]
- [Uno Toolkit Docs][uno-toolkit-docs]

[responsiveview-docs]: https://aka.platform.uno/toolkit-responsiveview
[responsiveextension-docs]: https://aka.platform.uno/toolkit-responsivemarkup
[m3-drawer-guidelines]: https://m3.material.io/components/navigation-drawer/guidelines
[m3-bottom-sheet]: https://m3.material.io/components/bottom-sheets/overview
[m3-side-sheet]: https://m3.material.io/components/side-sheets/overview
[winui-flyoutpresenterstyle]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.flyout.flyoutpresenterstyle?
[winui-flyout]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.flyout
[winui-flyoutpresenter]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.flyoutpresenter
[responsive-sample-gh]: https://github.com/kazo0/ResponsiveApp
[responsive-view-layout-docs]: https://aka.platform.uno/toolkit-responsiveview#responsivelayout
[responsive-view-layout-logic-docs]: https://aka.platform.uno/toolkit-responsiveview#resolution-logics
{% include links.md %}