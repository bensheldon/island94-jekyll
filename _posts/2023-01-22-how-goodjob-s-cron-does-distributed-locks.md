---
title: "How GoodJob's Cron does distributed locks"
date: 2023-01-22 10:18 PST
published: true
tags: [GoodJob]
---

[GoodJob](https://github.com/bensheldon/good_job) is a multithreaded, Postgres-based, ActiveJob backend for Ruby on Rails. GoodJob has many features that take it beyond ActiveJob. One such feature is [cron-like functionality](https://github.com/bensheldon/good_job/blob/994ecff5323bf0337e10464841128fda100750e6/README.md#cron-style-repeatingrecurring-jobs) that allows scheduling repeated jobs on a fixed schedule. 

This post is a brief technical story of how GoodJob prevents duplicated cron jobs from running in a multi-process, distributed environment.

_This is all true as of GoodJob's current version, 3.7.4._

### Briefly, how GoodJob's cron works

GoodJob heavily leans on `Concurrent::Ruby` high-level primitives, and the cron implementation is no different. [`GoodJob::CronManager`](https://github.com/bensheldon/good_job/blob/994ecff5323bf0337e10464841128fda100750e6/lib/good_job/cron_manager.rb) accepts a fixed hash of schedule configuration and feeds them into `Concurrent::ScheduledTask`s, which then trigger `perform_later` on the job classes at the prescribed times. 

A locking strategy is necessary. GoodJob can be running across multiple processes, across numerous isolated servers or containers, in one application. GoodJob should guarantee that at the scheduled time, only a single scheduled job is enqueued. 

### Initially, advisory locks

When [GoodJob's cron feature was first introduced in version 1.12](https://github.com/bensheldon/good_job/pull/297), Cron used an existing feature of GoodJob: [Concurrency Control](https://github.com/bensheldon/good_job/blob/994ecff5323bf0337e10464841128fda100750e6/README.md#activejob-concurrency). Concurrency Control places limits on how many jobs can be enqueued or performed at the same time.

Concurrency Control works by assigning jobs a "key" which is simply a queryable string. Before enqueuing jobs, GoodJob will count how many job records already exist with that same key and prevent the action if the count exceeds the configured limit. GoodJob uses advisory locks to avoid race conditions during this accounting phase.

There were some downsides to using Concurrency Control for Cron. 

- It was a burden on developers. Concurrency Control extends `ActiveJob::Base` and required the developer to configure Concurrency Control rules separately from the Cron configuration.
- It wasn't very performant. Concurrency Control's design is _optimistic_ and works best when collisions are rare or infrequent. But a large, clock-synchronized formation of GoodJob processes is a _pessimistic_ concurrency scenario, and it could take several seconds of advisory locking and unlocking across all the processes to insert a single job.
 
### Then, a unique index

GoodJob v2.5.0 [changed the cron locking strategy](https://github.com/bensheldon/good_job/pull/423). Instead of using Concurrency Control's advisory locks, GoodJob uses a unique compound index to prevent the same cron job from being enqueued/`INSERT`ed into the database multiple times.

- In addition to the existing `cron_key` column in job records, the change added a new timestamp column, `cron_at` to  store when the cron job is enqueued.
- Added a unique index on `[cron_key, cron_at]` to ensure that only one job is inserted for the given key and time.
- Handled the expected `ActiveRecord::RecordNotUnique` when multiple cron processes try to enqueue the same cron job simultaneously and the unique index prevents the `INSERT` from taking place

Now, when a thundering herd of GoodJob processes tries to enqueue the same cron job at the same time, the database uses its unique index constraint to prevent multiple job records from being created. Great!

### Does it do a good job?

Yes! I've received lots of positive feedback in the year+ since GoodJob's cron moved to a unique index locking strategy. From the application perspective, there's much less enqueueing latency using a unique index than when using advisory locks. And from the developer's perspective, it does _just work_ without additional configuration beyond the schedule.

Using a unique index does require preserving the job records for a bit after the jobs have been performed. Otherwise, poor clock synchronization across processes could lead to a duplicate job being inserted again if the job has already been performed and removed from the table/index. Fortunately, preserving job records should not be too burdensome because GoodJob will [automatically clean them up](https://github.com/bensheldon/good_job/blob/994ecff5323bf0337e10464841128fda100750e6/README.md#monitor-and-preserve-worked-jobs) too.

Lastly, one goal of writing this is the hope/fear that a Database Administrator will tell me this is a terrible strategy and provide a better one. Until that happens, I have confidence GoodJob's cron is good. [I'd love your feedback!](https://github.com/bensheldon/good_job/discussions/806)
