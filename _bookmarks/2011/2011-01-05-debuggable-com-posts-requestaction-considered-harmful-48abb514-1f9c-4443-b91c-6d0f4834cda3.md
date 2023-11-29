---
link: http://debuggable.com/posts/requestaction-considered-harmful:48abb514-1f9c-4443-b91c-6d0f4834cda3
date: 2011-01-05 13:41 UTC
published: true
title: requestAction considered harmful » Debuggable Ltd
tags:
- cakephp
- php
---

For one, the speed penalty of using requestAction is quite prohibitive. The main slowdown is that every time you call requestAction, a full dispatch cycle takes place. This is pretty inefficient given that you probably already know what exact Controller/action you want to call up. A much bigger reason is that you will create a debugging nightmare for yourself. As soon has you have requestAction calls that invoke requestAction calls that invoke requestAction calls - you're screwed. If somewhere along the chain odd things happen (like a bug in your Auth system, some controller's / component's beforeFilter) debugging is going to become a major pain.
