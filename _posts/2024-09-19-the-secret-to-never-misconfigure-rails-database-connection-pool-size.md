---
title: "The secret to calculate Rails database connection pool size"
date: 2024-09-19 07:33 PDT
published: true
tags: []
---

Ruby on Rails maintains a pool of database connections for Active Record. When a database connection is needed, a connection is checked out of the pool, and then returned to the pool. The size of the pool is configured in the `config/database.yml` with the `pool:` key. The default is `<%= %>


<blockquote markdown="1">



</blockquote>
