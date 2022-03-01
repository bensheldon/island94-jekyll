---
title: "Software models"
date: 2022-02-28 17:32 PST
published: true
tags:
---

Software design has been in my thoughts lately. Particularly _agile_ software design, in which the game is to re-design working software in response to changing business requirements in response to learnings from working software.

1. I was recently talking to a colleague about what I call "Strict" Technical Debt, which is how Ward Cunningham originally defined it (not YAGNI or Skimping [according to Ron Jeffries](https://ronjeffries.com/articles/019-01ff/iter-yagni-skimp/)). [Dave Rupert pulls out](https://daverupert.com/2020/11/technical-debt-as-a-lack-of-understanding/) the following quote from Ward Cunningham, as "Technical Debt as a lack of understanding":

> “If you develop a program for a long period of time by only adding features but never reorganizing it to reflect your understanding of those features, then eventually that program simply does not contain any understanding and all efforts to work on it take longer and longer.” 

2. This sentence from SICPER's ["Aphorism Considered Harmful"](https://www.sicpers.info/2022/02/aphorism-considered-harmful/) about the phrase "Make it work, make it right, make it fast":

<blockquote markdown="1">

So actually it looks like I had the wrong idea all this time: you don’t somehow make working software then correct software then fast software, you make working software and some inputs into that are the abstractions in the interfaces you design and the performance they permit in use. 

</blockquote>

Or as I interpret it: make it functional, then make the software design be an appropriate representation and model of the business/problem domain, and then make it appropriate/ergonomic for future developers to use or maintain.

3. I left this comment on Jason Swett's ["Why I don’t buy “duplication is cheaper than the wrong abstraction"](https://www.codewithjason.com/duplication-cheaper-wrong-abstraction/):

<blockquote markdown="1">

...The statement I use is “code duplication is better than the wrong business abstraction”.

A lot of these statements/concepts come out of Agile, Object-Oriented Programming, and Extreme Programming recognize that there are two things evolving unevenly: the understanding of the business domain, and then laggingly, the development of the code that models the understanding of the business domain.

A better expansion here as I understand the concept would be “duplication of code is acceptable if the proposed extraction/abstraction does not meaningfully model the current understanding of the business domain”.

The power of the statement, as I use it (and as I see these things go from Agile/OOPS/XP) is to push someone to get closer to the business domain (and the user) in their thinking/proposals/justifications and as a counterweight to DRY. The problem with these things is when they get imposed as a criticism, rather than the starting place of a conversation.

I think you give solid advice:

> Don’t try to make one thing act like two things. Instead, separate it into two things. If you feel reluctant to modify someone else’s code, ask why that is.

</blockquote>
