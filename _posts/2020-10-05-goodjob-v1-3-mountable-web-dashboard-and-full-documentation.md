---
date: '2020-10-05 11:24 -0700'
published: false
title: 'GoodJob v1.3: Mountable web dashboard and full documentation'
---
[GoodJob](https://github.com/bensheldon/good_job) version 1.3 is released. GoodJob is a multithreaded, Postgres-based, ActiveJob backend for Ruby on Rails. If you&#39;re new to GoodJob, read the [introductory blog post](https://island94.org/2020/07/introducing-goodjob-1-0).

GoodJob&#39;s v1.3 release adds a mountable Web Dashboard and improved README documentation and complete code-level YARD documentation.

Version 1.3&#39;s release comes five weeks after v1.2 and three months after GoodJob&#39;s initial v1.0 release.

## Shoutouts 🙌

GoodJob has accepted contributions from 9 people total, and currently has 559 stars on Github. The project just passed 150 combined Issues and Pull Requests.

I&#39;m grateful for everyone who has reached out to me on [Ruby on Rails Link Slack (@bensheldon)](https://www.rubyonrails.link/) and [Twitter (@bensheldon)](https://twitter.com/bensheldon)🙏

## Mountable web dashboard

GoodJob v1.3 adds a web dashboard for exploring and visualizing job status and queue health.

The web dashboard is implemented as an optional Rails::Engine and includes charts and lists of pending jobs.

I expect the web dashboard to be a hot area of ongoing improvement. This initial release contains a minimum functional interface, a chart, and some necessities like keyset pagination. The dashboard is familiar to develop (Rails Controllers, ERB Views and ActiveRecord), and I&#39;ve adopted Bootstrap CSS and Chartist to ease and speed development.

## Improved documentation

GoodJob&#39;s README has been edited and rewritten for clarity and comprehensiveness, and GoodJob&#39;s implementation code is now thoroughly documented with YARD.

Good documentation is vital for open source projects like GoodJob. I worked with [Rob Brackett](https://robbrackett.com/), who consults on complex software and open source challenges.

## Upcoming

In the next release, v1.4, I plan to continue adding views and charts to the web dashboard and improving thread management.

## Contribute

Code, documentation, and curiosity-based contributions are welcome! Check out the [GoodJob Backlog](https://github.com/bensheldon/good_job/projects/1), comment on or open a Github Issue, or make a Pull Request.

I also have a [GitHub Sponsors Profile](https://github.com/sponsors/bensheldon) if you&#39;re able to support GoodJob and me monetarily. It helps me stay in touch and send you project updates too.