---
date: '2021-01-10 20:12 -0800'
published: true
title: 'GoodJob 1.4: JRuby compatibility and more'
tags:
  - good_job
---
[GoodJob](https://github.com/bensheldon/good_job)  version 1.4 is released. GoodJob is a multithreaded, Postgres-based, ActiveJob backend for Ruby on Rails. If you’re new to GoodJob, read the  [introductory blog post](https://island94.org/2020/07/introducing-goodjob-1-0) .

GoodJob’s v1.4 release adds support for:

- JRuby
- MRI 3.0
- Rails 6.1
- Postgres 12+

And includes additional improvements to the Web Dashboard.

Version 1.4’s release comes three months after v1.3 and five months after GoodJob’s initial v1.0 release.

## JRuby compatibility
GoodJob 1.4 adds compatibility for Ruby on Rails applications running under JRuby. GoodJob's multithreading is built on top of [ConcurrentRuby](https://github.com/ruby-concurrency/concurrent-ruby), which provides consistent behavior and guarantees on all four of the main Ruby interpreters (MRI/CRuby, JRuby, Rubinius, TruffleRuby). 

A minor downside of JRuby is that JRuby's database adapter, [`activerecord-jdbc-adapter`](https://github.com/jruby/activerecord-jdbc-adapter), does not support Postgres LISTEN, which means GoodJob must rely on polling for new jobs under JRuby.

## Broader compatibility and improvements
In addition to JRuby, GoodJob 1.4 adds compatibility for MRI 3.0, Rails 6.1, and Postgres 12+. 

GoodJob 1.4 also includes improved filtering for the Web Dashboard,.

## What's next
The next version of GoodJob will add support for daemonization. 

## Contribute
Code, documentation, and curiosity-based contributions are welcome! Check out the  [GoodJob Backlog](https://github.com/bensheldon/good_job/projects/1) , comment on or open a Github Issue, or make a Pull Request.

I also have a  [GitHub Sponsors Profile](https://github.com/sponsors/bensheldon)  if you’re able to support GoodJob and me monetarily. It helps me stay in touch and send you project updates too.