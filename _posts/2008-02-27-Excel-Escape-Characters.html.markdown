---
title: Excel Escape Characters
date: '2008-02-27'
tags:
- spreadsheets
wp:post_type: post
redirects:
- node/203
- excel-escape-characters
- 2008/02/excel-escape-characters/
- "?p=203"
---

If you want to insert a parenthesis into an excel formula (for example, concatenating strings into something to export), you want do use double-double-quotes:

`
"I am ""cool"""
`

Produces the text string _I am "cool"_

A useful example is producing email addresses:

`

[In the Cold of the Night buy](http://www.iucn-tftsg.org/?in_the_cold_of_the_night)

=CONCATENATE("""",A2, """ ")
`
