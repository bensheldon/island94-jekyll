---
link: https://cate.blog/2026/10/13/attempting-to-reverse-engineer-code-review/
date: 2026-10-13 14:39 UTC
published: true
title: Attempting to reverse engineer code review
tags: []
---

So what is review doing? Enforcing things the team hasn’t necessarily agreed to. Some of what reviewers raised was really shared: everybody flagged leftover dead and debug code. A lot of it wasn’t. Dependency injection, the architecture rule that came up most, was raised by only half the reviewers. Asking for missing tests was something seven of the twelve did over the 20 months, but in the six weeks I audited, review asked for tests only about 14% of the time, mostly humans. And in 16 places a reviewer’s norm got pushed back on, and in a few of them reviewers wanted opposite things: for instance, whether a feature flag should be read at runtime or once at launch.

These are all reasonable stances to take, and it’s possible they were situationally dependent in ways that I don’t have insight into. But from this data, and for an individual onboarding, it would be hard to distinguish a team norm from one person’s preference. It’s muddier still when, as here, some of what read as a reviewer’s judgement was actually AI output transferred via C+P.
