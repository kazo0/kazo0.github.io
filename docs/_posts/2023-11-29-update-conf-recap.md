---
title: "Update Conference Recap"
category: conference
header:
  teaser: /assets/images/update-conf-2023/update-conf-2023-hero.jpg
tags: [conference, update-conference, uno-platform]
gallery:
  - image_path: /assets/images/update-conf-2023/update-conf-2023-hall.jpg
    alt: "Update Conference Hall"
    title: "Update Conference Hall"
  - image_path: /assets/images/update-conf-2023/update-conf-2023-hall2.jpg
    alt: "Update Conference Hall alternate view"
    title: "Update Conference Hall"
  - image_path: /assets/images/update-conf-2023/update-conf-2023-speaker-room.jpg
    alt: "Speaker Room"
    title: "Speaker Room"
  - image_path: /assets/images/update-conf-2023/update-conf-2023-speaker-gift.jpg
    alt: "placeholder image 3"
    title: "Speaker Gift"
gallery2:
  - image_path: /assets/images/update-conf-2023/prague-astro-clock.jpeg
  - image_path: /assets/images/update-conf-2023/prague-cathedral.jpeg
  - image_path: /assets/images/update-conf-2023/prague-tower.jpeg
  - image_path: /assets/images/update-conf-2023/prague-museum.jpeg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo1.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo2.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo5.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo6.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo9.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo11.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo12.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo13.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo14.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo15.jpg
  - image_path: /assets/images/update-conf-2023/prague-trip-photo16.jpg
---

I am currently sitting in the Schiphol Airport in Amsterdam waiting for my connecting flight back to Toronto after attending [Update Conference 2023][update-conf-site] in Prague, Czechia. This trip was full of firsts for me: first time in Prague, first time at Update Conference, first time speaking in Europe, and my first time meeting some of my Uno Platform teammates in person. It was an amazing experience and I still can't believe this was something I was able to do. I had a lot of fun and I am completely exhausted, so I figured I should write a recap instead of sleeping :upside_down_face:.

## The Conference

Update Conference Prague is the biggest .NET developer conference in Czechia. It's a two-day conference that has over 40 technical sessions led by experts from all around the world. The conference itself is, by far, the most well-put-together conference I've ever attended. The organizers did an AMAZING job and the conference hall was beautiful.

{% include gallery layout="half" %}

The conference hall was lined with booths from various sponsors, including Uno Platform! There was a chill-out room with games, comfy seats, and a coffee bar for attendees to relax in between sessions. There was also a quiet room to get some work done and a special speaker room to relax and prepare for your talk. And the food! THE FOOD! There was a constant flow of delicious snacks, sandwiches, and drinks throughout the day.

I also had the pleasure of meeting my fellow Uno Platform teammates, Martin Zikmund ([@mzikmunddev][martin-twitter]) and Dominik Titl ([@morning4coffe][dominik-twitter]), in person for the very first time. Both of them being for Czechia, they showed me a great time and introduced me to their favourite Czech food and drink.

![Dominik, Me, and Martin at Update Conf](/assets/images//update-conf-2023/update-conf-2023-uno-team.jpeg)

The three of us ran the Uno Platform booth for the full two days of the conference. Martin and I also gave a talk on the first day of the conference titled [Create Beautiful .NET Apps Faster with Uno Platform][update-conf-uno-talk]. The talk was recorded and you should eventually be able to view it on their [Update Now Portal][update-now-portal].

## The Talk

![Martin and I on stage](/assets/images/update-conf-2023/update-conf-talk.jpg)

The Uno Platform talk that Martin and I gave was one of the very first talks on the first day of the conference. Which worked out perfectly because I was able to enjoy the rest of the conference without having to feel nervous or worried. I treated this talk as just another learning experience since I was speaking alongside Martin, who is a seasoned veteran and an amazing speaker. I was able to witness firsthand how he prepares and delivers his material. I have already ~~stolen~~ incorporated some of his demos/material into my own Uno talks.

The talk went really well, I definitely rushed through my part as usual but I still think it was an overall improvement from [TechBash]({% post_url 2023-11-14-techbash-recap %}). I tried to utilize the feedback I got last time and force myself to pause as much as I could. To help that along, I brought a drink up to the podium with the intention of taking a sip every now and then to sprinkle in some pauses. I don't think I took a single sip. The moment I started to speak I totally forgot about it and raced through my slides and demos. You can probably see the top of the Coke bottle on the podium in the recording, just sitting there, so lonely and unused. Although unsuccessful in my attempt to slow things down, the intention was there. I think I need to practice taking breaks during my dry runs as well, that'll probably make it feel more natural to do when I'm on stage.

I was curious how well it would go having two speakers on stage together. I think Martin and I did a really good job of handing it off to each other. Given that we only split up the talk the evening before at the speaker dinner :grimacing:. The talk began with just a general introduction to what Uno Platform is and how it works and then we jumped straight into demos and code. First thing I wanted to show was [the Visual Studio wizard][uno-wizard] where we quickly got a new Uno app up and running. Once the project was created, I wanted to show people the platform in action right away, so we added a `Slider` and launched the app on as many platforms as time would allow.

```xml
<StackPanel>
    <TextBlock HorizontalAlignment="Center"
               FontSize="30"
               Text="{Binding Path=Value, ElementName=mySlider}" />
    <Slider x:Name="mySlider" />
</StackPanel>
```

<figure>
    <img src="/assets/images/update-conf-2023/update-conf-2023-slider.gif" alt="Example GIF of Slider demo"/>
    <figcaption><em>Slider example from the demo</em></figcaption>
</figure>

From there, we dove into some super interesting topics and demos including:

- [Uno Toolkit][uno-toolkit]
- [Uno Themes][uno-themes]
- [Uno Figma Plugin][uno-figma]
- [MVUX][uno-mvux]
- [Uno Extensions][uno-extensions]
- [C# Markup][csharp-markup]
- And more...

It was a lot of ground to cover but this time around we gave brief overviews on some topics and directed people towards the documentation/website for more information. This way we were able to stay focused instead of trying to cram in demos and explanations for every single detail of the platform. We had a couple questions at the end, mostly focused on how we differentiate ourselves from [Flutter][flutter] or [MAUI][maui]. The answer basically boils down to the [extra platforms][uno-platforms] that we support as well as our unique technique for [Lookless Controls][uno-ui-render-docs].

## The Booth

![Dominik and Martin at the Uno booth](/assets/images/update-conf-2023/update-conf-2023-uno-booth.jpg)

As a sponsor for the conference, Uno Platform had a booth in the main hall for both conference days. Who knew that sitting at a table for 8 hours straight talking about the same thing over and over could be so exhausting :sweat_smile:. I actually had a blast running the booth with Martin and Dominik.

During the down times, I got to know both of them much better compared to the quick Teams interactions we usually have whenever our time zones overlap. I got the impression that Martin is similar to myself in that we both need recovery time after so much social interaction. Dominik, on the other hand, is a social butterfly. Given his experience presenting at conferences for both Uno Platform and Microsoft, I shouldn't be surprised. Often, he would snap Martin and me out of our trance and point us to someone who was hovering around the booth and get us to engage with them. He was definitely the captain of the booth. Oh, and did I mention that he is just about to graduate from HIGH SCHOOL!? He is touring around with Uno and Microsoft, speaking at conferences, and contributing very important work to Uno, all while studying for his final year. This guy can multitask.

I also got to meet some really interesting people who came over to the booth to learn about Uno Platform. Including some very interested companies/groups whose information we handed over to the marketing/sales team as potential leads. Fingers crossed :crossed_fingers:! We even got to speak to one very excited individual who had written his own article about Uno Platform][billson-article] years ago and was totally pumped to see us.

## The Trip

This was my first time in Prague and I absolutely loved it. I spent a day and a half discovering the city before the conference started. I also took the weekend after the conference to travel to Kraków, Poland. I basically ate my way through Eastern Europe. While in Poland, I took the opportunity to visit Auschwitz I and Auschwitz II-Birkenau which had always been something I felt I needed to experience.

Instead of talking more about the leisure part of the trip, I'll just end this here and throw up a bunch of photos of the sights and the food. Enjoy!

**NOTE:** I'm not going to be posting any photos from Auschwitz
{: .notice--info}

{% include gallery id="gallery2" %}

[update-now-portal]: https://now.updateconference.net/
[update-conf-site]: https://www.updateconference.net/en
[martin-twitter]: https://twitter.com/mzikmunddev
[dominik-twitter]: https://twitter.com/morning4coffe
[update-conf-uno-talk]: https://www.updateconference.net/en/2023/session/create-beautiful--net-apps-faster-with-uno-platform
[uno-wizard]: https://platform.uno/docs/articles/getting-started/wizard/using-wizard.html
[flutter]: https://flutter.dev/
[maui]: https://learn.microsoft.com/en-us/dotnet/maui/what-is-maui
[uno-ui-render-docs]: https://platform.uno/docs/articles/how-uno-works.html#how-the-ui-is-rendered
[uno-platforms]: https://platform.uno/docs/articles/getting-started/requirements.html
[billson-article]: https://medium.com/hackernoon/cross-platform-mobile-apps-with-net-and-uno-dee2b024281d
{% include links.md %}