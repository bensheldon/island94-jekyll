---
link: http://cutfromthenorth.com/integrating-facebook-connect-with-cakephps-auth-component/
date: 2011-05-15 19:03 UTC
published: true
title: 'Integrating Facebook Connect with CakePHP’s Auth Component :: Cut from the
  North'
tags:
- cakephp
- facebook
---

NOTE: This post is out of date; working on an updated post to leverage the new Graph API

I wanted to be able to leverage all of the advantages of using Cake’s built in Auth component in my latest application; problem was that the application needed to allow for both normal user accounts and Facebook Connect generated user accounts. I struggled for a while to find the most seamless approach, and then it clicked — dynamically set Auth->fields.
