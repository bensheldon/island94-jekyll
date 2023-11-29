---
link: https://reasonablypolymorphic.com/blog/protos-are-wrong/
date: 2021-05-20 16:00 UTC
published: true
title: 'Protobuffers Are Wrong :: Reasonably Polymorphic'
tags: []
---

At the root of the problem is that Google conflates the meaning of data with its physical representation. When you’re at Google scale, this sort of thing probably makes sense. After all, they have an internal tool that allows you to compare the finances behind programmer hours vs network utilization vs the cost to store
x
x
 bytes vs all sorts of other things. Unlike most companies in the tech space, paying engineers is one of Google’s smallest expenses. Financially it makes sense for them to waste programmers’ time in order to shave off a few bytes.

Outside of the top five tech companies, none of us is within five orders of magnitude of being Google scale. Your startup cannot afford to waste engineer hours on shaving off bytes. But shaving off bytes and wasting programmers’ time in the process is exactly what protobuffers are optimized for.

Let’s face it. You are not Google scale and you never will be. Stop cargo-culting technology just because “Google uses it” and therefore “it’s an industry best-practice.”
