---
title: P, NP and Panlexicon
date: '2010-08-29'
tags:
- math
- panlexicon
wp:post_type: post
redirect_from:
- 2010/08/p-np-and-panlexicon/
- "?p=2142"
---

This week I updated [Panlexicon](http://panlexicon.com)'s Word of the Day for Twitter's new authentication API requirements, squeaking in just under the August 30 deadline. Panlexicon has been updated [tweeting a unique word every day](http://twitter.com/panlexicon) for nearly a year and a half now.

Also contemporary is [P ≠ NP](http://rjlipton.wordpress.com/2010/08/08/a-proof-that-p-is-not-equal-to-np/) and generating Panlexicon's daily tweet is an example of both Polynomial (P) and Non-Polynomial (NP) Time operations. Panlexicon's uniqueness comes from exploration and discovery; when thinking about how to bring Panlexicon to Twitter, ensuring those values came through lead to an interesting computational problem.

For every Word of the Day Panlexicon tweets, it also includes a number of related words. Any word of the day could have hundreds of related words, but the difficulty is in maximizing the number of related words to share in the tweet while still staying within Twitter's 140 character limit. The more related words I can fit into the tweet, and the more diverse those words are, the more explorational it is and the more likely you will discover something interesting or fun by reading it.

Generating Panlexicon's Word of the Day Twitter message is an NP-type problem. There are millions of potential solutions that stay within the 140 character limit, but only a few of them are optimal: fitting as many related words into the tweet as possible, while still having a diverse distribution of words lengths. There is no easy way to figure out those optimal solutions without a lot of computational muscle. At the same time _checking_ if the tweet as a whole is less than 140 characters is an N-type problem: it's just a simple matter of counting up the characters.

So that's just one example of the mathematical problems Panlexicon faces. Of course, the algorithm I actually use to write Panlexicon's Word of the Day on Twitter is by no means fully optimizing, but by keeping the broader computational context in mind, I can fake it reasonably well.
