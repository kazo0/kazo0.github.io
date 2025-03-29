---
title: "MVP Summit 2025 Recap"
category: conference
header:
  teaser: /assets/images/codemash-2025/badge-hero.jpg
  og_image: /assets/images/codemash-2025/badge-hero.jpg
tags: [conference, summit, mvp, microsoft, uno-platform, redmond, seattle]
---

Flying back from Seattle right now after a really fun week attending the Microsoft MVP Summit for the very first time. It was a whirlwind of sessions, networking opportunities, and squeezing in time to explore the Microsoft campus in Redmond, Washington. Last year, when I received the MVP award for the very first time, it was too late to register for the in-person experience. So I was really excited to be able to attend this year. Hoping that I will also be able to attend next year, assuming my renewal application is accepted :crossed_fingers:.

## The Sessions

Due to the nature of the MVP Summit, everything presented is under NDA so I can't share very much about the sessions I attended or their content.

![Animated GIF of Penguin from Madagascar](/assets/images/mvp-summit/penguin.gif){: .align-center}

## The People

There were a TON of familiar faces at the Summit, many that I've only interacted with through GitHub issues/discussions or on social media. Not only were there MVPs from all over the world, but there was also a bunch of Microsoft employees attending the sessions and the networking events.

### Team Uno Platform

I believe at this point, there are 5 MVPs on the core Uno team. Not every one of them were able to attend so it ended up being myself, [Jérôme Laban][laban-bsky] (Uno Platform CTO), and [Martin Zikmund][martin-twitter] (Uno Platform Engineer). Our other two MVPs, [Nick Randolph][randolph-blog] and [Andres Pineda][andres-twitter] were there with us in spirit.

<figure>
    <img src="/assets/images/mvp-summit/unocrew.jpg" alt="Myself, Martin, and Jerome at MVP Summit"/>
    <figcaption><em>Waiting in line for the keynote to kick off the Summit</em></figcaption>
</figure>

I was really grateful to have Martin and Jérôme there with me. If it had been just me attending solo I feel like I wouldn't have had the same experience. I'm not the most outgoing person and going to a networking event where I know absolutely no one sounds like my own personal version Hell. I would most probably would have just walked around a few times, stand awkwardly next to a few groups, pretend to listen and then perform one of my famous Irish Goodbyes to go work in the hotel room.

I feel Martin is similar to me in this way, at a certain point we hit our limit for social interaction for the day and it's time to shutdown and recharge. But, little did I know, Jérôme is a SOCIAL BUTTERFLY :butterfly:! So I just got to follow him around like a child and got introduced to a bunch of people, both MVPs and Microsoft employees. It was so much easier to have someone else there to break the ice. Of course, literally everyone there already knew who Jérôme was. I remember when I first met him around 10 years ago I was pretty sure he was a robot, no one can be THIS smart. I'm still not fully convinced.

Either way, I connected with a ton of people and even brainstormed some cool ideas with some of them that we could collaborate on during the year. I'd have to say the two highlights from these networking mixers were:

1. [Scott Hanselman][hanselman-bsky] told me I looked buff :muscle:
2. Talking with [Mads Torgersen][mads-linkedin] about all of the greenspace at the Microsoft campus and how we both loved walking through it all, smelling the pines and breathing in the fresh air.

I also got to introduce myself to the MAUI PMs: [David Ortinau][ortinau-twitter], [Beth Massi][massi-bsky], and [Rachel Kang][kang-bsky]. All super cool people. Was a little surprised that Ortinau already knew who I was. He said I'm very recognizable (which I'm gonna take as a good thing) and that I look just like my profile avatar. I think being bald is working in my favour. I didn't get a chance to say hi or introduce myself to [Maddy Montaquila][maddy-bsky] but I did see her around. I believe she is mostly on .NET Aspire stuff now.

I do, however, have an awkward photo that I took of David and Maddy because I was fanboying out telling my wife about all the important people that were around and she wanted to know who I was talking about.

<figure>
    <img src="/assets/images/mvp-summit/weird.jpg" alt="David and Maddy at Summit"/>
    <figcaption><em>Creepy stalker photo of David and Maddy</em></figcaption>
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
[laban-bsky]: https://bsky.app/profile/jlaban.bsky.
[martin-twitter]: https://twitter.com/mzikmunddev
[andres-twitter]: https://twitter.com/ajpinedam
[hanselman-bsky]: https://bsky.app/profile/scott.hanselman.com
[mads-linkedin]: https://www.linkedin.com/in/madst/
[ortinau-twitter]: https://x.com/davidortinau
[kang-bsky]: https://bsky.app/profile/therachelkang.bsky.social
[massi-bsky]: https://bsky.app/profile/bethmassi.net
[maddy-bsky]: https://bsky.app/profile/maddymontaquila.net
{% include links.md %}
