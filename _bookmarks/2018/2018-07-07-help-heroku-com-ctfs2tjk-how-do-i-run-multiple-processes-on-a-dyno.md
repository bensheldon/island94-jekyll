---
link: https://help.heroku.com/CTFS2TJK/how-do-i-run-multiple-processes-on-a-dyno
date: 2018-07-07 15:42 UTC
published: true
title: How do I run multiple processes on a dyno? - Heroku Help
tags:
- heroku
- rails
---

For my Ruby on Rails and Que needs.

<blockquote>web: puma -C config/puma.rb & sidekiq & wait -n</blockquote>
