---
title: GoodJob Updates v1.5 - v1.9: Dashboard, daemonize, async_server, and graceful shutdowns
date: 2021-05-31 20:14 PDT
published: true
tags: 
  - GoodJob
---

This is a quick roundup of what's new with GoodJob since the last update published for [GoodJob v1.4](https://island94.org/2021/01/goodjob-1-4-jruby-compatibility-and-more). 

GoodJob ([github](https://github.com/bensheldon/good_job)) is a multithreaded, Postgres-based, ActiveJob backend for Ruby on Rails. If you’re new to GoodJob, read the  [introductory blog post](https://island94.org/2020/07/introducing-goodjob-1-0) .

_For further details on the following updates, check out GoodJob's [Changelog](https://github.com/bensheldon/good_job/blob/main/CHANGELOG.md) or [Readme](https://github.com/bensheldon/good_job/blob/main/README.md)._

### GoodJob v1.5: Web Dashboard and Rails.config

GoodJob ships with a [web dashboard]() to display future, finished and errored jobs for easy inspection.  The Dashboard mounts as a self-contained Rails Engine.

GoodJob introduced a greater reliance on `Rails.application.config...` for improved autoloading compatibility. 

### GoodJob v1.6: Daemonize

GoodJob can run as a backgrounded daemon for folks who are still managing servers: `--daemonize`

### GoodJob v1.7: Scheduled job cache

GoodJob caches scheduled jobs (`ExampleJob.set(wait: 30.minutes).perform_later`) for significantly reduced latency without relying upon polling. 

### GoodJob v1.8: Graceful shutdown

GoodJob added additional shutdown options, including `GOOD_JOB_SHUTDOWN_TIMEOUT` to allow jobs to finish before exiting.

### GoodJob v1.9: async_server mode

GoodJob added an additional `async` execution mode to simplify the default configuration: running jobs as part of the web-process (and _not_ console, Rake commands, etc.)

### Upcoming: cron and concurrency controls

GoodJob will add support for cron-style repeating jobs, and concurrency controls to ensure that only a specified number (1 or more) jobs are enqueued or performed at the same time.  I previously was opposed to extending ActiveJob's interface, but [have changed my mind](https://github.com/bensheldon/good_job/issues/255); it's on!

### Contribute

Code, documentation, and curiosity-based contributions are welcome! Check out the  [GoodJob Backlog](https://github.com/bensheldon/good_job/projects/1), comment on or open a Github Issue, or make a Pull Request. **Thank you!!!** to everyone who has contributed to GoodJob, including morgoth, tedhexaflow, weh, lauer, reczy, zealot128, gadimbaylisahil, Mr0grog, thilo, arku, sj26, jm96441, thedanbob, and joshmn. 

I also have a [GitHub Sponsors Profile](https://github.com/sponsors/bensheldon) if you’re able to support GoodJob and me monetarily. It helps me stay in touch and send you project updates too.
