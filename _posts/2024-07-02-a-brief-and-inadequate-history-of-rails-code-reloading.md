---
title: "A brief and inadequate history of Rails code reloading and autoloading"
date: 2024-07-02 07:44 PDT
published: true
tags: []
---

I am circling around the strongly held belief that [code reloading and autoloading is _the_ most important design constraint](https://speakerdeck.com/bensheldon/an-ok-compromise-faster-development-by-designing-for-the-rails-autoloader) when designing or architecting for Ruby on Rails. 

- Code reloading is what powers the "make a code change, refresh the browser, see the result" development loop
- Code autoloading is what allows Rails to boot in milliseconds (if you've designed for it!) to run a single targeted test for tight test-driven-development loops

When it works, it works, and it probably isn't something you think about. When code autoloading and reloading doesn't work or works poorly, as it has on numerous apps across my career and consulting, it can be maddening:

- Spending hours "debugging" some code only to realize that your changes were never being run at all.
- Waiting tens of excruciatingly boring seconds to run a simple test or watching the browser churn away while it slowly waits for a response from the development server.

Code reloading and autoloading not working correctly is a huge pain. It's not great!

The history of code reloading and autoloading came up recently in the Rails Performance Slack. A young developer working on an old Rails application asked what Spork was (a forking preloader), and whether it was necessary (not necessarily). As a middle-aged Rails Developer (I started working with Rails in 2012, long after it first launched in 2004, but it's still been a minute), I realized I had some experience here.

Over history, various strategies have been taken to make the development loop faster because that's so important. Those strategies usually boil down to:

- Separating the (static) framework code from the (changing, developed) application code and only loading, just in time, what's needed for the part of the application that's currently running.
- Loading/booting the framework code that is unlikely to change, and then only (re-)load the application code when invoking a command or running a test.

There have been various approaches to doing this:

- Forking Preloaders (Spork, though Spring is the more contemporary version): load up the framework code in a process once, then fork into a subprocess when you invoke a command and reload just the application code. Sometimes, things can get out of sync (some application code or state pollutes the primary process), and things get weird/confusing. This is why you’ll hear of people hating on Spring or complaining, “I wasted all day on a development bug, and it turns out I just needed to restart Spring” (the analogous “it was DNS all along” of the Rails world).
Bootsnap, though operating on a cache strategy rather than a process-forker, serves a similar purpose of trying to speed up an application's loading time. The adoption of Bootsnap, and much, much faster CPUs in general, has largely replaced the usage of Spring in applications (though it's still okay!).
- Zeitwerk autoloader also plays a role in this history because it, too, is trying to “solve” the necessity of separating the framework code (which changes infrequently) from the application code during development (which is actively being changed) to produce faster development feedback cycles. Zeitwerk replaced the previous autoloader built into Rails, whose lineage seems to date all the way back to [Rails 2.0 circa 2005](https://github.com/bensheldon/rails/commit/ee014ef95ae9746b4228f3bc7c85ac0df28ba1df). Tell me the history if you know it!

A lot of labor has gone into this stuff. It's important! And it's easy to get wrong and produce a slow and disordered application where development is a pain. It happens! A lot!

[todo]



<blockquote markdown="1">



</blockquote>
