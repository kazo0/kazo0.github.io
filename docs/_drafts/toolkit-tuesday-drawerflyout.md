---
title: "Toolkit Tuesdays: DrawerFlyoutPresenter"
category: toolkit-tuesday
header:
  teaser: /assets/images/uno-toolkit-hero.png
  og_image: /assets/images/uno-toolkit-hero.png
tags: [uno-toolkit, toolkit, drawerflyout, drawer, drawerflyoutpresenter, uno-platform, uno, unoplatform]
---

Welcome to another edition of Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][toolkit-homepage] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-homepage]. I hope you find them useful too!

This week we are covering the `DrawerFlyoutPresenter`, a lightweight way to create a [drawer-like experience][m3-drawer-guidelines] in your applications using [Flyouts][winui-flyout]. It can also be utilized for other experiences such as a [bottom sheet][m3-bottom-sheet] or a [side sheet][m3-side-sheet]. In this article we will cover both the "navigation drawer" and "bottom sheet" use cases.

## Anatomy of a `DrawerFlyoutPresenter`

### As a Navigation Drawer



### As a Bottom Sheet

## ResponsiveView

The `ResponsiveView` control is a new control that is used to help build responsive layouts. It is a container control that can be used to define different layouts for different screen sizes. It is similar to how [`VisualStateManager.AdaptiveTrigger`][winui-adaptive-trigger] allows you to define breakpoints for different screen sizes, but it is much more powerful and flexible without needing to rely on [VisualStates][winui-visual-state].

`ResponsiveView` adapts to the current screen width and applies the appropriate layout template. Since not all templates need to be defined, the control ensures a smooth user experience by picking the smallest defined template that satisfies the width requirements. If no match is found, it defaults to the largest defined template.

### Properties

| Property            | Type               | Description                                             |
| ------------------- | ------------------ | ------------------------------------------------------- |
| `NarrowestTemplate` | `DataTemplate`     | Template to be displayed on the narrowest screen size.  |
| `NarrowTemplate`    | `DataTemplate`     | Template to be displayed on a narrow screen size.       |
| `NormalTemplate`    | `DataTemplate`     | Template to be displayed on a normal screen size.       |
| `WideTemplate`      | `DataTemplate`     | Template to be displayed on a wide screen size.         |
| `WidestTemplate`    | `DataTemplate`     | Template to be displayed on the widest screen size.     |
| `ResponsiveLayout`  | `ResponsiveLayout` | Overrides the screen size threshold/breakpoints.        |

The `ResponsiveLayout` property is used to override the default screen size threshold/breakpoints. We will cover this in more detail [later](#responsivelayout).
{: .notice--info}

### Usage

So, let's take the following XAML as an example:

```xml
<Page xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:local="using:ResponsiveApp"
      xmlns:utu="using:Uno.Toolkit.UI"
      x:Class="ResponsiveApp.MainPage"
      Background="{ThemeResource ApplicationPageBackgroundThemeBrush}">
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
        <utu:ResponsiveView.NarrowTemplate>
            <DataTemplate>
                <Grid Background="Green">
                    <TextBlock Text="Narrow Template"
                               FontSize="32" />
                </Grid>
            </DataTemplate>
        </utu:ResponsiveView.NarrowTemplate>
        <utu:ResponsiveView.NormalTemplate>
            <DataTemplate>
                <Grid Background="Blue">
                    <TextBlock Text="Normal Template"
                               FontSize="32" />
                </Grid>
            </DataTemplate>
        </utu:ResponsiveView.NormalTemplate>
        <utu:ResponsiveView.WideTemplate>
            <DataTemplate>
                <Grid Background="Purple">
                    <TextBlock Text="Wide Template"
                               FontSize="32" />
                </Grid>
            </DataTemplate> 
        </utu:ResponsiveView.WideTemplate>
        <utu:ResponsiveView.WidestTemplate>
            <DataTemplate>
                <Grid Background="Orange">
                    <TextBlock Text="Widest Template"
                               FontSize="32" />
                </Grid>
            </DataTemplate>
        </utu:ResponsiveView.WidestTemplate>
    </utu:ResponsiveView>
</Page>
```

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
[winui-adaptive-trigger]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.adaptivetrigger
[winui-flyout]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.flyout
[responsive-sample-gh]: https://github.com/kazo0/ResponsiveApp
[responsive-view-layout-docs]: https://aka.platform.uno/toolkit-responsiveview#responsivelayout
[responsive-view-layout-logic-docs]: https://aka.platform.uno/toolkit-responsiveview#resolution-logics
{% include links.md %}