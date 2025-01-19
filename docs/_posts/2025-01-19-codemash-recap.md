---
title: "CodeMash 2025 Recap"
category: conference
header:
  teaser: /assets/images/codemash-2025/badge-hero.jpg
  og_image: /assets/images/codemash-2025/badge-hero.jpg
tags: [conference, codemash-conference, codemash, uno-platform, sandusky]
---

I am currently on the train heading back home after a long day of travel. I am returning from wintry Sandusky, Ohio where I attended [CodeMash 2025][codemash-site]. This was not my first time at CodeMash, I actually attended it several other times when I was living in Columbus, Ohio from 2016-2020. I always had a great time at the conference and I was excited to be able to attend again this year, this time as a speaker! After many submissions to CodeMash over the years, I finally got accepted for my general intro to Uno Platform talk. I actually ended up giving two talks! It was a lot of fun and also very exhausting :)

## The Conference

CodeMash is more of a general conference that educates developers on current practices, methodologies and technology trends in various platforms and development languages. It is held in the middle of Winter in Sandusky, Ohio at the [Kalahari Resort][kalahari-site]. The resort is a massive indoor waterpark with a hotel attached. As I mentioned earlier, I had actually been to a few previous CodeMash events while I was living in Columbus, Ohio. I was excited to see some familiar faces as my previous employer in Columbus always has a large presence at the conference as well as some friends I made while consulting at different companies in the area.

This was my first time back in Ohio since moving back home to Canada in 2020. Since then, I have been submitting abstracts for talks on Uno Platform each year in the hopes of going back to CodeMash. I was so happy to finally get accepted this year. CodeMash had always been such a huge conference every time I went and I felt like it was a big accomplishment to get accepted to such a large conference.

After receiving my acceptance and excitedly sharing the news with the team, Uno Platform decided to sponsor the conference as well. Of course, this now meant I couldn't just hermit up in my room and work before and after my sessions. Instead, I had to work the booth and speak with a lot of the attendees. It was actually really great to be able to talk to people about Uno Platform and get their feedback on the platform. I met people with so many different expertise in different technologies, not just .NET developers. It was pretty cool to just be able to nerd out and talk about tech in general.

Of course, there's no way I could've handled it alone and I was incredibly grateful to have my colleague [Matthew Mattei][mattei-twitter] there to basically run the whole booth while I sat there frantically jumping between work priorities, demo creation, and practicing for the upcoming talk. Matt is our Dev Marketing guru and handles all of the content creation efforts that we do at Uno Platform. If you've ever watched any of our [Uno Platform Tech Bite videos][tech-bite-yt], Matt is the one behind the scenes making it all happen.

<figure>
    <img src="/assets/images/codemash-2025/booth-crowd.jpg" alt="Crowd at the Uno Platform booth"/>
    <figcaption><em>Matt handling the crowds at the Uno Platform booth</em></figcaption>
</figure>

## The Talk(s)

A couple of days before leaving for CodeMash, I found out we would also have the opportunity to speak at a "sponsored session" on the Thursday afternoon. It was a perfect opportunity to talk about Uno Platform's new [Hot Design™][hot-design-page] technology. If you haven't looked into Hot Design™ yet, be sure to check out the [announcement at .NET Conf][hot-design-announcement] this past November with [Nick Randolph][randolph-blog] and [Jerome Laban][laban-twitter].

For the sponsored session, I took inspiration from Nick's segment at .NET Conf and basically rebuilt an entire page from one of our reference sample apps without ever needing to write a single line of XAML. The Chefs app that Nick and I used in the demos is an upcoming reference app that we will be releasing soon. It is a much larger sample app than our other samples as the goal is to highlight best practices when building Uno Platform apps. This includes usage of almost everything in the Uno Toolkit, Uno Material Theme, Uno Extensions (including Navigation and MVUX), and extensive usage of the core controls from Uno itself.

<figure>
    <img src="/assets/images/codemash-2025/hd-chefs.png" alt="Chefs app running in Hot Design mode"/>
    <figcaption><em>Chefs app while in Hot Design mode</em></figcaption>
</figure>

The session went really well and the demo gods were in my favor. People looked pretty excited about Hot Design and seemed to be really impressed with the way Hot Design can inspect the current `DataContext` of whatever element is selected and be able to generate `Binding`s directly from the property editor pane. I ended the session by steering the crowd toward our booth and to sign up for the [waitlist][hot-design-waitlist] as Hot Design is currently still in private beta.

The next day (Friday) I had my original session scheduled for 4pm and I was really worried that no one would be there since Friday was also the last day of the conference. I was pleasantly surprised that there were quite a few people who stayed until the very end of the conference. Overall, I think I did just _okay_. I've been told that I am noticeably more relaxed and at ease at about the 10-minute mark when I am presenting. The first 10 minutes are just a sweaty, shaky shitshow. I need to find a way to come out of the gate calm, cool, and collected. At this point, I think I just need to focus more on practicing, doing dry runs, and presenting for the dog at home, just so I get more comfortable. Either way, all the demos worked and there were a couple of good questions at the end. One question was concerning how to handle changes to the UI based on the platform and/or form factor. The answer is that you have multiple options available to you:

- [XAML conditional prefixes][conditional-xaml]
- [Adaptive Triggers][adaptive-triggers]
- [Uno Toolkit Responsive Extensions][responsive-ext]

## The People

I really enjoy conferences since you get to meet new people and hear what they are working on, but you also get to see familiar faces and catch up with people that you only really ever see at conferences a few times a year.

The first night there, Matt and I went down to the Thursday Night Party in the hopes of somehow getting the Montreal Canadiens game on one of the TVs at the bar. When we asked the bartender if they could put it on he looked at us like we were crazy people and told us there's no way they have the channel for something like that. So, being good Canadians, we sat at a table and propped up my phone and streamed the hockey game from there.

We were also able to flag down [Alvin Ashcraft][alvin-site] and get him to sit with us which was awesome. Alvin is a world-class speaker, Senior Content Developer at Microsoft, and the organizer of the [TechBash conference][techbash-site]. We sat at the table and just hung out, talking about conferences, tech, life, etc. Before leaving for the night, he handed us a little card for the upcoming TechBash 2025 conference and encouraged us to submit! TechBash will take place November 4-7, 2025. If you've never been you should definitely check it out. TechBash is also hosted in the Kalahari Resort but at the Poconos (Pennsylvania) location. If you wanted to know more about it, I also did a [recap for TechBash]({% post_url 2023-11-14-techbash-recap %}) last time I was there.

![TechBash 2025 card](/assets/images/codemash-2025/techbash-card.jpg)

During my second talk on Friday afternoon, I saw a few familiar faces in the crowd. Including [Matt Eland][eland-site], who I first met at a couple of user groups when I was living in Columbus. Matt is an author, Microsoft MVP, and a self-proclaimed "Professional Wizard". It was good to catch up after the talk and he introduced me to his colleague [Sam Gomez][gomez-twitter]. They are both part of the team that runs the [Stir Trek conference][stir-trek] in Columbus, Ohio. They actually encouraged me to submit to speak there as well as see if perhaps Uno Platform could sponsor and have a presence at the conference! I really liked attending Stir Trek when I was in Columbus and it'd be fun to go back one day.

## The End

Overall, it was a great conference. I'm happy I was able to speak and feel motivated to keep submitting to conferences. Although, last year I bit off more than I could chew and completely burned myself out from all of the travel. I'll need to find a good balance this year and not overcommit myself. I'm looking forward to the next conference, which will be [ConFoo][confoo-site] in my hometown of Montreal. I'll be speaking about [building a .NET YouTube player using Uno Platform][confoo-talk] . I'm thinking of making some small tweaks so we could actually showcase some of Hot Design while we are building the app live.

Catch you in the next one :wave:

[codemash-site]: https://codemash.org/
[mattei-twitter]: https://x.com/matteiomattei
[tech-bite-yt]: https://www.youtube.com/playlist?list=PLl_OlDcUya9rP_fDcFrHWV3DuP7KhQKRA
[hot-design-page]: https://platform.uno/hot-design/
[hot-design-waitlist]: https://platform.uno/waitlist/
[hot-design-announcement]: https://youtu.be/sJPyieyt1Rc?si=-ppfqj3l-JtmeLk6
[conditional-xaml]: https://platform.uno/docs/articles/platform-specific-xaml.html
[adaptive-triggers]: https://platform.uno/docs/articles/features/AdaptiveTrigger.html
[responsive-ext]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/responsive-extension.html
[alvin-site]: https://www.alvinashcraft.com/
[techbash-site]: https://techbash.com/
[eland-site]: https://matteland.dev/
[stir-trek]: https://stirtrek.com/
[gomez-twitter]: https://x.com/thesoccerdev
[randolph-blog]: https://nicksnettravels.builttoroam.com/
[laban-twitter]: https://x.com/jlaban
[kalahari-site]: https://www.kalahariresorts.com/ohio/
[confoo-talk]: https://confoo.ca/en/2025/session/let-s-build-a-net-youtube-player-for-all-platforms
[confoo-site]: https://confoo.ca/en/2025
{% include links.md %}
