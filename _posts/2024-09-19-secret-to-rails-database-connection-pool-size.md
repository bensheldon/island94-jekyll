---
title: "The secret to perfectly calculate Rails database connection pool size"
date: 2024-09-19 07:33 PDT
published: true
tags: [Rails]
---

Ruby on Rails [maintains a pool of database connections](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html) for Active Record. When a database connection is needed for querying the database, usually one per thread (though [that's changing to per-transaction](https://github.com/rails/rails/pull/51349)), a connection is checked out of the pool, used, and then returned to the pool. The size of the pool is configured in the `config/database.yml`. The [default](https://github.com/rails/rails/blob/dfd1e951aa1aeef06c39fffb2994db8a8fa1914f/railties/lib/rails/generators/rails/app/templates/config/databases/postgresql.yml.tt#L20), as of Rails 7.2, is `pool: <%%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>`.

The database connection pool size is frequently misconfigured. *A lot.* How to calculate the database connection pool size is one of the most common questions I get on GoodJob (Hi! I’m the author of GoodJob 👋). I have spent an embarrassingly large amount of time trying to come up with a precise pool size calculator and give advice to take into account Puma threads, and GoodJob async jobs, and `load_async` queries and everything that might be asking for a database connection at the same time. It’s nearly impossible to get the number exactly right.

If the connection pool is misconfigured to be _too small_ , it can slow down web requests and jobs while waiting for a connection to become available, or raise `ActiveRecord::ConnectionTimeoutError` if there isn’t a connection available within a reasonable amount of time (5 seconds by default). That’s bad! We never want that to happen. Here’s what you should do:

**✨ The secret to perfectly calculate Rails database connection pool size:** _Don’t! Set the pool size to a very large, constant number, and never worry about it again. E.g. `pool: 100`._

WAIT, WHAT?! Why? I described that bad things happen if the pool size is *too small*. Here’s the trick: it’s impossible to set the connection pool size to be _too big_. You can’t do it! That’s why it’s always better to set a number that’s too large. And the best number is one that can _never_ be too small regardless of how you configure (and inevitably reconfigure) your application. Here’s why:

- Database connections are lazily created and added to the pool _as they’re needed_. Your Rails application will never create more database connections than it needs. And the database connection pool reaper removes idle and unused connections from the pool. The pool will never be larger than it needs to be.
- It’s possible you may run out of available database connections _at the database_. For example, Heroku’s new `Essentials-0` Postgres database only has 20 database connections available globally. But that’s not because the database connection pool is too big, it’s because your application is *using too many concurrent database connections*.
- If you find yourself in the situation where your application is using too many concurrent database connections, you should be configuring and re-sizing _the things using database connections concurrently_, not the database connection pool itself:
  - Configure the number of Puma threads
  - Configure the number of GoodJob async threads (Solid Queue now has similar functionality too!)
  - Configure the `load_async` thread pool
  - Configure anything else using a background thread making database queries
  - Configure the number of parallel processes/Puma workers/dynos/containers you’re using, which the database connection pool has no effect on anyways.
- If you still don't have enough database connections _at the database_, then you should increase the number of database connections _at the database_. Which means scaling your database, or using a connection multiplexer like PgBouncer.
- If, in an incredibly rare case, your application concurrency is very, very spiky and you worry that idle database connections are sitting in the connection pool for too long before they are automatically removed by the connection pool reaper, then configure that:
  - `idle_timeout`: number of seconds that a connection will be kept unused in the pool before it is automatically disconnected (default: 5 minutes). Set this to zero to keep connections forever.
  - `reaping_frequency`: number of seconds between invocations of the database connection pool reaper to disconnect and remove unused connections from the pool (default: 1 minute)

I know this is wild advice, but it’s based on facts and experience. Even Rails maintainers have intentions [to remove this configuration option entirely](https://github.com/rails/rails/pull/51073#issuecomment-1942762197):

>  …we want the pool not to have a limit by default anymore.

So please, stop sweating the precise, exact, perfect database connection pool value. Set it to something really big, that can never be too small, and never worry about it again.
