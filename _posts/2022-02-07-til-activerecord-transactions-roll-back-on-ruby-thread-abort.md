---
title: "TIL: ActiveRecord transactions roll back on Ruby Thread abort"
date: 2022-02-07 19:54 PST
published: true
tags:
---

I learned that ActiveRecord would roll back transactions when inside an aborted theead. It's implemented right here, in ActiveRecord's [connection_adapters/abstract/transaction.rb](https://github.com/rails/rails/blob/3f13828392a4aea81184fa873c47cb2e53d295e9/activerecord/lib/active_record/connection_adapters/abstract/transaction.rb#L336-L342):

```ruby
def within_new_transaction
  # ...
ensure
  # ...
  elsif Thread.current.status == "aborting" || (!completed && transaction.written)
    # The transaction is still open but the block returned earlier.
    #
    # The block could return early because of a timeout or because the thread is aborting,
    # so we are rolling back to make sure the timeout didn't caused the transaction to be
    # committed incompletely.
    rollback_transaction
  # ...
end
```

How did I end up here? I recently implemented a feature in GoodJob to track active processes in the database using ActiveRecord. These database queries occur in a background thread where I also use the same database connection for GoodJob's Postgres LISTENing. It looks something like this (pseudocode):

```ruby
Concurrent::Future.execute do
  process = Process.create
  loop { listen_for_notify }
ensure
  process&.destroy!
end
```

While working on one of my Rails projects that use GoodJob (https://dayoftheshirt.com), I noticed that Process records were not cleaned up as I expected running when GoodJob async inside of Rails Server/Puma locally and exiting. Inspecting the logs, I saw this:

```text
TRANSACTION (0.1ms)  BEGIN
GoodJob::Process Destroy (0.3ms)  DELETE FROM "good_job_processes" WHERE "good_job_processes"."id" = $1  [["id", "320de861-4c84-4f8c-ba3e-2e08a8ef0469"]]
TRANSACTION (0.1ms)  ROLLBACK
```

Huh. I did some Googling and found some [references to rollback behavior](https://github.com/rails/rails/pull/40704#discussion_r532007113), and asked in the Rails Link Slack, but nobody knew. This caused me to dig in ActiveRecord, where I found the behavior implemented.

I was still confused because I had never seen this behavior in GoodJob when building out the feature. But after much head-scratching, I realized that I hadn't followed [GoodJob's README instructions for integrating with Puma](https://github.com/bensheldon/good_job#execute-jobs-async--in-process), which ensures that GoodJob is gracefully shutdown before Ruby aborts threads at exit:

```ruby
config/puma.rb

on_worker_shutdown do
  GoodJob.shutdown
end

MAIN_PID = Process.pid
at_exit do
  GoodJob.shutdown if Process.pid == MAIN_PID
end
```

Mystery solved.
