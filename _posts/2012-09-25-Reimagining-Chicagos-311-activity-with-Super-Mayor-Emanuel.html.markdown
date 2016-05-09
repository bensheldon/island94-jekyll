---
title: Reimagining Chicago's 311 activity with Super Mayor Emanuel
date: '2012-09-25'
tags:
- analytics
- data
- open311
- portfolio
wp:post_type: post
redirect_from:
- 2012/11/reimagining-chicagos-311-activity-with-super-mayor-emanuel/
- 2012/09/reimagining-chicagos-311-activity-with-super-mayor-emanuel/
- "?p=3057"
---

![](/uploads/2012-09/screenshot-600x437.png "screenshot")

  [Super Mayor Emanuel](http://supermayor.io) is one of the goofier applications I've built at Code for America: [**supermayor.io**](http://supermayor.io)

**Boring explanation:** Using data from Chicago's Open311 API the app lists, in near-realtime, service requests within the City of Chicago's 311 system that have recently been created, updated or closed.

**Awesome explanation:** The mayor runs through the streets of Chicago, leaping over newly-reported civic issues and collecting coins as those civic problems are fixed.

I really like this application, not only because of its visual style, but because it lets you engage with the 311 data in a completely novel way: aurally. Turn up those speakers and let the website run in the background for about 30 minutes. Spinies (new requests) come in waves, and coin blocks (updated/closed requests) are disappointingly rare. Sure, I could have just created a chart of statistics, but I think actually _experiencing_ requests as they come in makes you think differently about both the people who submitted a request and the 311 operators and city staff who are receiving them (just think about what caused those restaurant complaints... or maybe don't).

The application is built with Node.js, which fetches and caches 311 requests, and a Backbone-based web-app, communicating via socket.io, which manages all of interface and animation. The source is on [Github](https://github.com/codeforamerica/super-mayor).

 
