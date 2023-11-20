---
layout: post
title: Toolkit Tuesdays - NavigationBar
category: toolkit-tuesday
tags: [uno-toolkit, navigation-bar, uno-platform]
---

Welcome to the first post in my new series, Toolkit Tuesdays! In this series, I'll be highlighting some of the controls and helpers in the [Uno Toolkit][uno-toolkit] library. This library is a collection of controls and helpers that we've created to make life easier when building apps with [Uno Platform][uno-platform]. I hope you find them useful too!

This week we are covering the NavigationBar control. This control has a simple purpose with a complex and interesting implementation across the multiple platforms that Uno supports. On Android and iOS/Catalyst, the NavigationBar serves as a sort of proxy to the native Android Toolbar and iOS UINavigationBar. On all other platforms, its functionality and UI are driven by a customized CommandBar. 

## MainCommand

The crown jewel of the NavigationBar is the MainCommand property, which automatically hooks itself to the back button on Android and iOS/Catalyst. This allows you to easily set up a back button in your app without having to write any platform-specific code. The NavigationBar is smart enough to know when it is displayed within a Frame that currently contains items in the BackStack and will automatically show the back button. If the Frame is at the root of the navigation stack, the back button will be hidden.

## MainCommandMode

Of course, the NavigationBar is built is customizability in mind. You can override all of this built-in navigation logic by setting the `MainCommandMode` property to `Action` instead of the default `Back`. Using `Action` tells the NavigationBar to short-circuit the built-in navigation logic and simply execute the command that is set to the `MainCommand` property. This is useful if you want to have a hamburger menu or other navigation pattern that doesn't rely on the built-in back button.

## PrimaryCommands and SecondaryCommands

The NavigationBar also supports the `PrimaryCommands` and `SecondaryCommands` properties, which are collections of `AppBarButton` controls. `PrimaryCommands` are displayed on the right side of the NavigationBar, given there is enough space to display them. While `SecondaryCommands`, along with `PrimaryCommands` that don't fit in the bar, are placed in an "overflow" popup menu accessible from an ellipsis button at the end of the bar. The NavigationBar will automatically adjust the layout of these buttons based on the available space on the screen. On Android and iOS/Catalyst, the buttons will be displayed in the native Toolbar/NavigationBar. On all other platforms, the buttons will be displayed in a CommandBar.

{% include links.md %}