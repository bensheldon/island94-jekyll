---
title: Meet Ravel!
date: '2013-07-26'
tags: []
wp:post_type: post
redirects:
- 2013/07/meet-ravel/
- "?p=3098"
---

[ ![ravel-screens](/uploads/2013-07/ravel-screens.png) ](2013-07-26-Meet-Ravel/ravel-screens.png)

I’ve spent the last 6 months working at OkCupid Labs building an iOS native mobile app I’m very proud of: [Ravel!—”Share Photos. Meet People.”](http://ravelapp.com/) We’ve described it as a dating app for Instagrammers: your public profile is the photos that you pull in from Instagram, Facebook or your camera roll and you can introduce yourself and start chatting with other people based on the photos they share.

We built Ravel! using RubyMotion, a toolchain for writing native iOS apps in (nearly)Ruby. In building it, I learned a lot more both about Ruby and Objective-C along with the intricacies of developing for a mobile device. The mobile app is powered by a Rails-based API server, which is also the backend for the website (for sharing your photo and profile via the web). One of the strengths of RubyMotion is its wonderful automation tools; and the drawbacks is that it's memory management still has requires some work and workarounds. Perhaps you've seen [this quote](http://sealedabstract.com/rants/why-mobile-web-apps-are-slow/): "It’s not just you. I’m experiencing these memory-related types of crashes (like SIGSEGV and SIGBUS) with about 10-20% of users in production." That was me on the RubyMotion mailing list.

I also learned a lot of about instrumentation and building a consumer-facing app. Even though a lot of our focus was on in-app engagement, we also invested a lot of time in growth and retention. From optimizing the download  and App Store texts, to adding events and triggers in-app and on the server, to adding sharing and open graph integration through Facebook and on the web.

As I cycle off of Ravel!, time will tell how it survives as a product, but I'm very proud of how we brought it to market.
