---
date: '2020-08-19 20:51 -0700'
published: true
title: 'GoodJob v1.2: Multithreaded queue isolation and LISTEN/NOTIFY'
---
[GoodJob](https://github.com/bensheldon/good_job) version 1.2 has been released. GoodJob is a multithreaded, Postgres-based, ActiveJob backend for Ruby on Rails. If you’re new to GoodJob, read the [introductory blog post](https://island94.org/2020/07/introducing-goodjob-1-0).

GoodJob’s v1.2 release adds  multithreaded queue isolation for easier congestion management, and usage of Postgres LISTEN/NOTIFY to greatly reduce queue latency. 

Version 1.2 comes out 2 weeks after GoodJob v1.1, and 5 weeks after GoodJob's initial v1.0 release.

## Multithreaded queue isolation

GoodJob v1.2 adds multithreaded queue isolation for easier congestion management. Queue isolation ensures that slow, long-running jobs do not block the execution of higher priority jobs.

Achieving queue isolation has always been possible by running multiple processes, but GoodJob v1.2 makes it easy to configure multiple isolated thread-pools within a single process. 

For example, to create a pool of 2 threads working from the `mice` queue, and 1 thread working from the `elephants` queue:

```bash
$ bundle exec good_job --queues="mice:2;elephants:1"
```

Or via an environment variable:

```bash
$ GOOD_JOB_QUEUS="mice:2;elephants:1" bundle exec good_job
```

Additional examples and syntax:

- `--queues=*:2;mice,sparrows:1` will create two thread-pools, one running jobs on any queue, and another dedicated to `mice` and `sparrows` queued jobs.
- `--queues=-elephants,whales:2;elephants,whales:1` will create two thread-pools, one running jobs from any queue *except* the `elephants` or `whales`, and another dedicated to `elephants` and `whales` queued jobs.

## LISTEN/NOTIFY

GoodJob now uses Postgres LISTEN/NOTIFY to push newly enqueued jobs for immediate execution.  LISTEN/NOTIFY greatly reduces queue latency, the time between when a job is enqueued and execution begins.

LISTEN/NOTIFY works alongside GoodJob’s polling mechanism.  Together, jobs queued for immediate execution (`ExampleJob.perform_later`) are executed immediately, while future scheduled jobs (`ExampleJob.set(wait: 1.hour).perform_later`) are executed at (or near) their set time. 
 
## Upcoming

In the next release, v1.3, I plan to include a simple web dashboard for inspecting job execution performance, and focus on improving GoodJob’s documentation.

## Contribute

Code, documentation, and curiousity-based contributions are welcome! Check out the [GoodJob Backlog](https://github.com/bensheldon/good_job/projects/1), comment on or open a Github Issue, or make a Pull Request. 

I’ve also set up a [GitHub Sponsors Profile](https://github.com/sponsors/bensheldon) if you’re able to support me and GoodJob monetarily. It helps me stay in touch and send you project updates too.