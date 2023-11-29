---
link: https://gomakethings.com/better-more-accessible-active-link-styling/
date: 2020-05-15 15:53 UTC
published: true
title: Better (more accessible) active link styling | Go Make Things
tags: []
---

Until this morning, I always styled the current link in my navigation menu by doing this.
<ul class="nav"> <li><a href="/about">About</a></li> <li class="active"><a href="/articles">Daily Tips</a></li> <li><a href="resources">Learn JS</a></li> </ul>.nav .active a { border-bottom: 0.125em solid #fa7176; color: #272727; } It gives users a clear visual indication that “you are here.”
Well… sighted users, that is. If you’re visually impaired or use a screen reader to navigate the web, it tells you nothing.
