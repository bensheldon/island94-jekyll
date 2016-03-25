---
title: Content Map
date: '2005-11-26'
tags: []
wp:post_type: post
redirects:
- node/15
- content-map
- 2005/11/content-map/
- "?p=15"
---

This is an example of my googlemap module that I extended from [this module](http://drupal.org/node/29091) by [bjornarneson](http://choirgeek.com/).

It creates map points through parsing local RSS feeds that Drupal produces. Normally these feeds only contain the last 15 posts, but I hacked together a helper module (fullfeed.module) that uses taxonomy.module urls (with cool term parsing) but adds _all_ content in the term (or terms) to the feed.

With each feed I can define a custom marker (.png files I created and uploaded). The markers are all default size and shadow—this is limiting, but it’s a PITA to modify it.

The workflow for this is relatively easy. Pure latitude and longitude data is inputed via location.module—I grab it from maps.google.com because I couldn’t get the geocoding from an address to work, though many of my nodes are from random places and this is much more accurate. I have a vocabulary setup just for mapped nodes (photos, videos, random thoughts, etc), and use these as my feeds. Custom icons I created and FTPed in, though you could just use upload.module and attach them to your map node.

It currently does not support lines, though I am definitely planning on adding them. but I don’t have a good idea of workflow though, considering there is not a standard RSS element and am not sure if it’s going to be too hard to either…

The module now supports lines as a nodeapi hook (like location.module adds lat/long). Each feed can set a custom line color. I don’t know workflow yet whether to keep it like this, or have color on a per-node basis.

There is still the line issue of:

- define a new namespace (I have no clue on how to do this)
- coopt an existing but unused element and pray we don’t break anything
- parse a static xml file that would somehow be specified in a node

Lastly, there is an issue with posting more than one map on a page (it breaks). This is because every map sets things in the header, and I’m not sure what is the best way to make sure that they only post the important stuff _once_ when there is a list of them.
