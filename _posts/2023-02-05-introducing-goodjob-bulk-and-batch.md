---
title: "Introducing GoodJob Bulk and Batch"
date: 2023-02-05 14:37 PST
published: true
tags: [GoodJob]
---

GoodJob is a multithreaded, Postgres-based, ActiveJob backend for Ruby on Rails. I recently released two new features:

- `GoodJob::Bulk` to optimize enqueuing large numbers of jobs (released in GoodJob v3.9)
- `GoodJob::Batch` to coordinate parallelized sets of jobs (released in GoodJob v3.10)

Big thanks to @julik, @mollerhoj, @v2kovac, @danielwestendorf, @jrochkind, @mperham and others for your help and counsel!

### Bulk enqueue

[GoodJob's Bulk-enqueue functionality](https://github.com/bensheldon/good_job#bulk-enqueue) can buffer and enqueue multiple jobs at once, using a single INSERT statement. This can be more performant when enqueuing a large number of jobs.

I was inspired by a discussion within a Rails pull request to implement [`perform_all_later` within Active Job](https://github.com/rails/rails/pull/46603). I wanted to both support the way most people enqueue Active Job jobs with `perform_later` and also [encourage people to work directly with Active Job instances too](https://github.com/rails/rails/pull/43434).

```ruby
# perform_later within a block
active_jobs = GoodJob::Bulk.enqueue do
  MyJob.perform_later
  AnotherJob.perform_later
end
# or with Active Job instances
active_jobs = [MyJob.new, AnotherJob.new]
GoodJob::Bulk.enqueue(active_jobs)
``` 

Releasing Bulk functionality was a two-step: I initially implemented it while working on Batch functionality, and then with @julik's initiative and help, we extracted and polished it to be used on its own.

### Batches

[GoodJob's Batch functionality](https://github.com/bensheldon/good_job#batches) coordinates parallelized sets of jobs. The ability to coordinate a set of jobs, and run callbacks during lifecycle events, has been a highly demanded feature. Most people who talked to me about job batches were familiar with [Sidekiq Pro](https://sidekiq.org/products/pro.html) 's [batch functionality](https://github.com/mperham/sidekiq/wiki/Batches]), which I didn't want to simply recreate (Sidekiq Pro is excellent!). So I've been collecting use cases and thinking about what's most in the spirit of Rails, Active Job, and Postgres:

- Batches are mutable, database-backed objects with foreign-key relationships to sets of job records.
- Batches have  `properties` which use Active Job's serializer, so they can contain and rehydrate any GlobalID object, like Active Record models.
- Batches have callbacks, which are themselves Active Job jobs

Here's a simple example: 

```ruby
GoodJob::Batch.enqueue(on_finish: MyBatchCallbackJob, user: current_user) do
  MyJob.perform_later
  OtherJob.perform_later
end

# When these jobs have finished, it will enqueue your `MyBatchCallbackJob.perform_later(batch, options)`
class MyBatchCallbackJob < ApplicationJob
  # Callback jobs must accept a `batch` and `params` argument
  def perform(batch, params)
    # The batch object will contain the Batch's properties, which are mutable
    batch.properties[:user] # => <User id: 1, ...>
    # Params is a hash containing additional context (more may be added in the future)
    params[:event] # => :finish, :success, :discard
  end
end
```

There's more depth and examples in the [GoodJob Batch documentation](https://github.com/bensheldon/good_job#batches). 

### Please help!

Batches are definitely a work in progress, and I'd love your feedback:

- What is the Batch functionality missing? Tell me your use cases.
- Help improve the [Web Dashboard UI](https://goodjob-demo.herokuapp.com/good_job/jobs) (it’s rough but functional!)
- Find bugs! I'm sure there are some edge cases I overlooked.
