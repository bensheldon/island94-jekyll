---
date: '2019-04-25 07:39 -0700'
published: true
title: 'Quantitative usability, assistive technology, and the right to privacy'
tags:
  - assistive technology
  - lighthouse labs
---
You have a _legal obligation_ to produce an accessible website; these are some thoughts about what comes next.

At [Lighthouse Labs](http://lighthouse-sf.org/lighthouse-labs/) this month, there was a lively discussion on “Detecting accessibility events, a debate on the ethics and implications of this new feature from Apple” [[article](https://www.applevis.com/blog/apple-assistive-technology-ios-macos-news/apple-shares-information-its-new-accessibility-events)]. I offered this in the pre-discussion email thread:

> I wanted to share some perspective as a web developer: I would like to have aggregated analytics about what screen-readers are using my website (how many and which ones). Here’s why:  
>   
> Within an agile process, once we achieve the baseline of WCAG/valid/passable/usable, the question becomes how do we make it even better and where do we start? Being able to point to analytics is useful for prioritization discussions about bottlenecks/friction. For example, on GetCalFresh.org, which has helped 700k people apply for food stamps, we can identify completion differences between, for example, English and Spanish-language users on particular parts of an application flow, and prioritize improvements based on frequency and severity. I don’t have the data to do that kind of prioritization for screen-readers, but I would like to.  

The Lighthouse Labs discussion brought up several dimensions of the issues:

- People with disabilities are legally protected from discrimination, and have legal rights to privacy of their conditions and freedom from discrimination.
- If the lived experience is a spectrum of “discrimination - inaccessibility - accommodation - accessibility - usability” (these are my words, imprecise), the majority of experience lives towards the left of that spectrum. Everyone has a story of being identified as a _low value / low priority_ user. 
- Some people would like to be fully and accessibly served; others would like to remain apart; everyone wants individual agency in that decision. An example of this was some people saying “I want websites to be completely accessible” and others saying “I’m fine not experiencing advertising and junk”. This came up as “ghettoization”, but I have been thinking about it as the difference between exclusion and seclusion.
- Differentiating between _accessibility_, _accommodation_ and _discrimination_ in digital products is important yet slippery. An example: Twitter’s native iOS client generally works with Voiceover (accessible), but used a separated streamlined UI for composing a tweet when the app detected that VoiceOver was in use (accommodation); when Twitter changed to 280 characters, they failed to update that sheet in a timely manner (discrimination). [[article](https://theoutline.com/post/2458/there-are-still-some-people-on-twitter-who-don-t-have-280-characters?zd=1&zi=zktxaedi)]

When discussing this with a my data science coworker, she shared [“Counting the Countless: Why data science is a profound threat for queer people”](https://reallifemag.com/counting-the-countless/) by Os Keyes:

> So: trans existences are built around fluidity, contextuality, and autonomy, and administrative systems are fundamentally opposed to that. Attempts to negotiate and compromise with those systems (and the state that oversees them) tend to just legitimize the state, while leaving the most vulnerable among us out in the cold. This is important to keep in mind as we veer toward data science, because in many respects data science can be seen as an extension of those administrative logics: It’s gussied-up statistics, after all — the “science of the state.”  
>   
> …perhaps a more accurate definition of data science would be:*The inhumane reduction of humanity down to what can be counted.*  

Within the context of assistive technology, it is not a far leap between tracking screenreader usage and creating an implication of _a_ disability and the segmentation that comes with it.

These discussions have made me think a lot more about my own digital footprints. I frequently use VoiceOver to explore websites and mobile apps and I now wonder about the impact/risks of being tracked and weigh them against the benefits to my own design practice and discernment, of which quantitative analysis is a tool.

_If you have thoughts about this post, quantitative usability testing and advanced product management for assistive technology and disabilities, I’d love to chat. Tweet me at [@bensheldon](https://twitter.com/bensheldon) or email me at [bensheldon@gmail.com](mailto:bensheldon@gmail.com)._
