---
title: "NDC Copenhagen DevFest 2024 Recap"
category: conference
header:
  teaser: /assets/images/cphdevfest-2024/cph-hero.jpg
  og_image: /assets/images/cphdevfest-2024/cph-hero.jpg
tags: [conference, ndc-conference, uno-platform, cphdevfest, copenhagen]
conference_gallery:
  - image_path: /assets/images/cphdevfest-2024/cph-conf1.jpg
    url: /assets/images/cphdevfest-2024/cph-conf1.jpg
    alt: "CPH DevFest Signs"
    title: "CPH DevFest Signs"
  - image_path: /assets/images/cphdevfest-2024/cph-conf3.jpg
    url: /assets/images/cphdevfest-2024/cph-conf3.jpg
    alt: "DevFest Conference Hall"
    title: "DevFest Conference Hall"
  - image_path: /assets/images/cphdevfest-2024/cph-conf4.jpg
    url: /assets/images/cphdevfest-2024/cph-conf4.jpg
    alt: "DevFest Conference Hall 2"
    title: "DevFest Conference Hall"
  - image_path: /assets/images/cphdevfest-2024/cph-conf5.jpg
    url: /assets/images/cphdevfest-2024/cph-conf5.jpg
    alt: "DevFest Conference Hall 3"
    title: "DevFest Conference Hall"
  - image_path: /assets/images/cphdevfest-2024/cph-conf6.jpg
    url: /assets/images/cphdevfest-2024/cph-conf6.jpg
    alt: "DevFest Conference Hall 4"
    title: "DevFest Conference Hall"
  - image_path: /assets/images/cphdevfest-2024/cph-conf9.jpg
    url: /assets/images/cphdevfest-2024/cph-conf9.jpg
    alt: "DevFest Downing Sessions"
    title: "Me at Heather Downing's session"
trip_gallery:
  - image_path: /assets/images/cphdevfest-2024/copenhagen-1.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-1.jpg
    alt: "Copenhagen City Photo 1"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-2.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-2.jpg
    alt: "Copenhagen City Photo 2"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-3.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-3.jpg
    alt: "Copenhagen City Photo 3"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-4.jpg  
    url: /assets/images/cphdevfest-2024/copenhagen-4.jpg
    alt: "Copenhagen City Photo 4"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-5.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-5.jpg
    alt: "Copenhagen City Photo 5"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-6.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-6.jpg
    alt: "Copenhagen City Photo 6"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-7.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-7.jpg
    alt: "Copenhagen City Photo 7"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-8.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-8.jpg
    alt: "Copenhagen City Photo 8"
    title: "Copenhagen Photos"
  - image_path: /assets/images/cphdevfest-2024/copenhagen-9.jpg
    url: /assets/images/cphdevfest-2024/copenhagen-9.jpg
    alt: "Copenhagen City Photo 9"
    title: "Copenhagen Photos"
---

We are back with another conference recap! This time, I had the pleasure of attending [NDC Copenhagen DevFest 2024][cph-devfest-site] in Copenhagen, Denmark. This was my first time attending an NDC event and I was very excited to see what it was all about. I was also looking forward to visiting Copenhagen for the first time. I had heard so many great things about the city and I was eager to explore it.

## The Conference

The Copenhagen Developers Festival is run by [NDC Conferences][ndc-site] and is a 5-day event for software developers with 2 workshop days, 3 days of conference talks, and 2 "festival evenings" with live music, entertainment, etc. This was my first time attending an NDC conference and I can tell you, they do not disappoint. Good food, good talks, and good people. What more could you ask for?

{% include gallery id="conference_gallery" %}

The conference hall was lined with booths from various sponsors, no Uno Platform this time :wink:. There was a spot to play Super Smash Bros. on the N64, although we all know that Melee for the GameCube is the superior version. There were little mobile "barista stations" where you could get some nice espresso. They even had a booth setup for ad-hoc demos where you could just hook up your machine and show off your project to anyone who was interested. I thought that was a really cool idea.

I didn't have the responsibility of running any sort of Uno Platform booth so I was free to attend sessions and wander around. I was able to catch a few talks but these were the two that stood out to me the most:

I attended a talk by [Heather Downing][downing-twitter] on ["Mobile App Architecture"][downing-talk] which was really insightful. Heather broke down the pros and cons of native mobile development versus cross-platform versus hybrid/web solutions. I was curious if I would see an Uno Platform mention during the presentation but she mostly focused on MAUI/XF and React Native. Heather walked us through different scenarios where the native approach may be best and others where xplat may be the better option. She also shared some stories from the trenches surrounding an _UNNAMED .NET CROSS-PLATFORM FRAMEWORK_ that she had worked with in the past :wink:. Specifically, her battles working with two runtimes at the same time, the .NET CLR and the JVM. As an engineer who works on a .NET cross-platform framework, I could definitely relate to some of the pain points she was describing. `ObjectDisposedException` anyone?

I also attended a talk by [Nico Vermeir][vermeir-twitter] on ["Porting Doom to MAUI"][nico-talk] which was also very interesting. Nico introduced us to the [open-source WPF port of Doom][doom-wpf]. That was the starting point for his MAUI port. The major change needed was based around the fact that MAUI does not have a `WriteableBitmap` class like WPF does. Nico had to come up with a way to render the game to a [`SkiaSharp`][skia-sharp] `SkCanvasView` instead with an `SkBitmap`. He also had to deal with the fact that MAUI has a different API for queueing up work on the UI thread. Nico was able to get the game running on MAUI with a few tweaks and it was really cool to see it in action. Since there is also SkiaSharp support for all platforms that Uno targets, we should be able to get a nice port of Doom running on Uno as well. Which means introducing Doom to WASM and Linux! I am thinking of reaching out to Nico and getting an Uno Platform version included in the repo.

## The Talk

![Me giving the Uno Platform Talk](/assets/images/cphdevfest-2024/me-talking.png)

I had a session on the morning of the last day of the conference. The talk was titled ["Let's build a .NET YouTube player for which platform? All of them!"][cpf-session-page-mine]. This was my first time giving this talk. It is more of a deep dive into building an entire app from scratch using Uno Platform. I am used to giving my [general introduction to Uno Platform talk][uno-intro-talk] so this was a nice change of pace.

This talk is based on the [TubePlayer Workshop][tubeplayer-workshop] that we have created. The workshop is a step-by-step guide to building a YouTube player app using Uno Platform. The app is built using the [MVUX pattern][mvux-docs] and demonstrates how to use various Uno Platform features such as `Extensions`, `Toolkit`, and more. We start off with mock data and a basic UI and slowly build up to a fully functional app that can search for and play YouTube videos using the actual APIs from YouTube.

I wasn't sure if I was going to be able to fit every single step of the workshop into an hour session so I created [my own GitHub repo][tubeplayer-repo] with the final version of the app as well as branches for each step of the workshop. This way, if I wanted to skip ahead, I could just checkout the branch for that step and continue from there. I ended up needing to do this a few times to keep the talk on track.

As another way to speed things up and avoid having to type every line of code live, I found this handy Visual Studio extension called [DemoSnippets][demo-snippets] by [Matt Lacey][lacey-twitter]. This extension allows you to create a list of code snippets that you can insert into your code file with a single click. I created snippets for each step of the workshop and was able to quickly add the code to the project without having to type it all out. The snippets get loaded into the Visual Studio Toolbox, which you might be familiar with if you ever built WPF/WinForms apps. I also used the names of the snippets as a summary/outline of the talk so I could refer to that instead of having to remember every single detail.

![DemoSnippets in action](/assets/images/cphdevfest-2024/demo-snippets.png)

I think the talk went well, there were a few people that came up with some questions. One person wanted more details on how the [Uno Platform Figma Plugin][figma-plugin] was being used to show a live preview of the app as well as extract the generated UI code. Another person actually asked me about the DemoSnippets extension that I was using, they thought it was pretty interesting.

I did a slightly better job at incorporating pauses and water breaks into the talk. It was also helpful to use the time it took to build and launch the app at several intervals to take a break and let people absorb what I had just shown. I still need to work on my pacing and not rush through the content. I still find myself running out of breath during the first few minutes of the talk, need to remember to breathe in between sentences :sweat_smile:.

## The Trip

Copenhagen is amazing. I had an awesome time exploring the city with my wife and eating amazing food. We visited so many cool places like Nyhavn, Tivoli Gardens, Freetown Christiania. We also explored the Assistens Cemetery where Niels Bohr and Hans Christian Andersen are buried.

The highlight of the trip was being able to eat at [Noma][noma], which is considered one of the best restaurants in the world. The food was incredible and the service was top-notch. We had the full tasting menu with the non-alcoholic beverage pairing. It was a once-in-a-lifetime experience that I will never forget. We actually were able to grab a reservation through the [r/NomaReservations subreddit][noma-reddit]. Another couple had a table for 4 and needed to fill the other two seats at the table. We took a chance and made a sketchy money transfer to them in the hopes that it wasn't a scam. It all worked out in the end and we had a great time together. The night ended with a private tour of the kitchen as I'm sure was their way to get us to leave since we had been there for 5 hours.

This was such an amazing trip. I have submitted to the other NDC conferences, next one up is [NDC Lodon][ndc-london]. Hopefully, I can do this talk again soon and maybe get a chance to visit London.

{% include gallery id="trip_gallery" %}

[cph-devfest-site]: https://cphdevfest.com/
[cpf-session-page-mine]: https://cphdevfest.com/agenda/lets-build-a-net-youtube-player-for-which-platform-all-of-them-0jla/0msoy34upc1
[downing-twitter]: https://x.com/quorralyne
[vermeir-twitter]: https://x.com/NicoVermeir
[lacey-twitter]: https://x.com/mrlacey
[ndc-site]: https://ndcconferences.com/
[downing-talk]: https://cphdevfest.com/agenda/mobile-app-architecture-how-to-conquer-the-giant-0wgk/0l58y0v6ra9
[nico-talk]: https://cphdevfest.com/agenda/from-hell-to-heaven-porting-doom-to-maui-0atn/0v0o6tbhuod
[doom-wpf]: https://github.com/wcabus/doom-sharp
[skia-sharp]: https://github.com/mono/SkiaSharp
[uno-intro-talk]: https://sessionize.com/s/steve-bilogan/net-apps-everywhere/66417
[tubeplayer-workshop]: https://aka.platform.uno/tubeplayer-workshop
[mvux-docs]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Overview.html
[tubeplayer-repo]: https://github.com/kazo0/TubePlayer
[demo-snippets]: https://github.com/mrlacey/DemoSnippets
[figma-plugin]: https://platform.uno/unofigma/
[noma]: https://noma.dk/
[noma-reddit]: https://www.reddit.com/r/NomaReservations/
[ndc-london]: https://ndclondon.com/
{% include links.md %}
