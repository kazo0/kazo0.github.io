---
title: "Introducing Uno Chefs (and some other stuff)"
category: uno-general
header:
  teaser: /assets/images/chefs-intro/chefslogo.png
  og_image: /assets/images/chefs-intro/chefslogo.png
tags: [release, hotdesign, chefs, hot-design, uno-platform]
chefs_gallery:
  - image_path: /assets/images/mvp-summit/altura8.jpg
    url: /assets/images/mvp-summit/altura8.jpg
  - image_path: /assets/images/mvp-summit/altura7.jpg
    url: /assets/images/mvp-summit/altura7.jpg
  - image_path: /assets/images/mvp-summit/altura6.jpg
    url: /assets/images/mvp-summit/altura6.jpg
  - image_path: /assets/images/mvp-summit/altura5.jpg
    url: /assets/images/mvp-summit/altura5.jpg
  - image_path: /assets/images/mvp-summit/altura4.jpg
    url: /assets/images/mvp-summit/altura4.jpg
  - image_path: /assets/images/mvp-summit/altura3.jpg
    url: /assets/images/mvp-summit/altura3.jpg
  - image_path: /assets/images/mvp-summit/altura2.jpg
    url: /assets/images/mvp-summit/altura2.jpg
  - image_path: /assets/images/mvp-summit/altura1.jpg
    url: /assets/images/mvp-summit/altura1.jpg
---

Uno Platform 6.0 has been released!

Be sure to check out the [release blog][release-blog] as well as the [Release Webinar][release-webinar] for full details and some really cool demos!

There are some truly amazing features in this release. Biggest of all are the general availability of Hot Design® and the introduction of Skia-based rendering for all platforms. Along with the official release blog, you should also check out [Nick's blog post][nick-blog] for further coverage of the new features.

What I'll be focusing on in this post is the release of [Uno Chefs][gh-chefs], our new flagship reference implementation when it comes to building cross-platform apps. You better get used to hearing about Chefs, because there is a boatload of content coming your way over the next few months. This means new [Tech Bites][yt-tech-bites], blog posts, and a growing collection of companion documentation articles that we've dubbed the ["Recipe Book"][docs-recipe-book].

## What is Uno Chefs?

As the [official docs][docs-chefs] states: Uno Chefs is a modern, responsive, and interactive recipe app built to show what Uno Platform can really do in a real-world, production-ready application. Basically, we took everything we offer in terms of our entire platform and shoved it into a single app. Chefs contains all the bells and whistles you can think of, including:

- **Uno Toolkit**: Ranging from complex controls like the `NavigationBar` to helpers like the `Responsive` Markup Extensions
- **Uno Material**: A complete Material Design implementation
- **Uno Extensions**: DI, MVUX, HTTP (Kiota), Auth, Navigation, and more
- **Media Player**: A fully functional, and free, media player
- **Third-Party Controls**: LiveChart2, MapsUI

On top of that, the Chefs app is built against the new Unified Skia Rendering Engine from Uno 6.0. Which means that the app is rendered using SkiaSharp for **Every.** **Single.** **Platform.**

## Anatomy of the Welcome Page

Let's dive in and take a tour of the app. Upon launching the app, you should find yourself on the Welcome Page. This page presents you with a carousel-like experience to demonstrate how you can build a first-launch onboarding experience that you see in many apps today.

### Wide Layout

<figure>
    <a href="/assets/images/chefs-intro/welcome-wide.png"><img src="/assets/images/chefs-intro/welcome-wide.png" alt="Welcome Page Anatomy"/></a>
    <figcaption>
        <ol>
            <li>TabBarItem</li>
            <li>TabBarItem Icon</li>
            <li>TabBarItem Content</li>
            <li>Custom Selection Indicator Content</li>
        </ol>
    </figcaption>
</figure>

## Narrow Layout
<figure>
    <a href="/assets/images/chefs-intro/welcome-narrow.png"><img src="/assets/images/chefs-intro/welcome-narrow.png" alt="Welcome Page Anatomy"/></a>
    <figcaption>
        <ol>
            <li>TabBarItem</li>
            <li>TabBarItem Icon</li>
            <li>TabBarItem Content</li>
            <li>Custom Selection Indicator Content</li>
        </ol>
    </figcaption>

[release-webinar]: https://www.youtube.com/live/xV8kIfqhuuA?si=hW4IyliKjTpJr82C
[release-blog]: https://platform.uno/blog/uno-platform-studio-6-0/
[nick-blog]: https://nicksnettravelswp.builttoroam.com/uno-platform-6-0/
[gh-chefs]: https://github.com/unoplatform/uno.chefs
[yt-tech-bites]: https://www.youtube.com/playlist?list=PLl_OlDcUya9rP_fDcFrHWV3DuP7KhQKRA
[docs-recipe-book]: https://aka.platform.uno/chefs-recipebooks
[docs-chefs]: https://aka.platform.uno/chefs-sampleapp

{% include links.md %}
