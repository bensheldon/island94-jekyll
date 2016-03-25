---
title: Thesaurus computations
date: '2007-09-03'
tags:
- thesaurus
wp:post_type: post
redirects:
- node/147
- thesaurus-computations
- 2007/09/thesaurus-computations/
- "?p=147"
---

Today I just started computing the relations between groups. It's been chugging along on my local machine for about 8 hours now, I'm 1% complete and have a table with 5 million entries (at 210mb).

If a word is shared between two groups, it forms an edge between those two groups. I'm storing that edge as the two group ids and the "overlap" value (the number of words shared between those two groups).

My algorithm is iterating through every word, finding the groups that the word is a part of, and creating an edge between them---computing overlap as it goes. I expect the rate to fall off as duplicate edges are thrown out.... but we'll see.
