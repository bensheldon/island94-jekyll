---
title: "What the fuck are you talking about?": The story of Nodetiles
date: 2022-07-13 22:31 PDT
published: true
tags:
---



_I recently lost access to my 10-year old Code for America email address when I changed jobs. I tried to preserve some of the good stuff and this is one story._

During my time as a Code for America Fellow in 2012, I created a Javascript-based slippy map tile rendered called Nodetiles (kinda sorta like Mapnik).  I had several colleagues vastly expand it, we presented at NACIS, and I know of at least one successful company that is still powered by forked version of it today. 

**Tom**

On April 25, 2012, I sent this email to Tom Carden:

> This week I came across a gist of yours and eventually made my way to nodemap while researching how to generate server-side map tiles. Thank you so much for putting those pieces together; they're fantastic! I matched your code with node-canvas-heroku to get it running in the cloud and it's pretty fantastic:
> 
>  [http://morning-spring-2292.herokuapp.com/](http://morning-spring-2292.herokuapp.com/) 
> 
> Anyways, just wanted to send you a big thanks for the code and inspiration. I'm working on building a node-based utfgrid renderer to bootstrap an entire wax interaction layer... all without Mapnik (though maybe I should just work on packaging that for Heroku).
> 
> Cheers,
> Ben

Tom gave some helpful advice and caveat emptor about JS performance and data caching. He continued to follow up with nodecanvas and cairo suggestions for getting stuff running on Heroku. Tom ended up being a Code for America mentor for a different project and he was the source of us using the Toner map style in demos and also a nice leaflet clustering plugin.

**Rob**

Rob Brackett was the first person I explained what I was doing attempting to create a tile render in Javascript. His reaction, to my explanation, was "What the fuck are you talking about?" Rob is one of my best friends, and I don't remember how I explained what would become Nodetiles then, but I'm sure it wasn't a linear train of thought.

On May 2, 2012 I sent this email to "Fuzz", Code for America's random-nerdsnipe list:

<blockquote markdown="1">

Last week Rob and I built a heroku-compatible map-tile renderer (and UTFGrid generator) that can quickly (and with low bandwidth/client-processing) serve interactive maps and markers comprising tens of thousands of points and polygons---and unlike TileMill, the final map can be connected to a live database and updated on-the-fly. It's kind've badass.

Here are 2 examples:

1. Static map of San Francisco streets and Parks: 
 [http://morning-spring-2292.herokuapp.com/](http://morning-spring-2292.herokuapp.com/) 

2. Map of all ~1.5k Occupy sites worldwide (I did this in about 15min, so it's a little clunky):
 [http://occupy-map.herokuapp.com/](http://occupy-map.herokuapp.com/) 

In terms of why it's badass (from less to more geeky):

1. It's fast. Nothing is rendered in the browser, instead all of the tiles are rendered and streamed to the browser as PNGs.
2. It's small. No shapefiles are sent to the browser. Each Map (the entire initial pageload) is less than 500kb.
3. It can do dynamic data. TileMill makes beautiful maps, but once you export them to MapBox (or your own mbtile server), you can't change them. This can be hooked up to a live database (right now it parses geojson).
4. It runs on Heroku. It uses node-canvas (not Mapnik) so it is fast, lightweight and has few dependencies.
5. It renders UTFGrids, which can provide mouse-hovers and other straightforward UI stuff that most maps don't (way less clicky)
6. It's not a tileserver, it's a tile *renderer*. Seriously, all those maptiles are being generated on on-the-fly (we should probably cache them, but hey, this is bleeding edge)
7. It's nodejs and all the code is on Github:  [https://github.com/bensheldon/nodetiles](https://github.com/bensheldon/nodetiles)  

I'm still working on it, so if you have a big dataset that you've had trouble mapping before, let me know since I'm looking for more/better use cases.

</blockquote>

**Prashant**

Prashant Singh, another Code for America fellow, was excited about the project and gave me lots of feedback. Prashant was using my project to generate large static maps from the commandline, and he gave some feedback on his experience doing similar work with Mapnik. Prashant and two other Fellows, Alicia Roualt and Matt Hampel, would subsequently build a business on top of it.

On June 5, 2012 I sent this email to Eric Gunderson at Mapbox:

<blockquote mardown="1">

I haven't done a big writeup yet. I'm hoping to submit to NACIS for their October conference, but I'm still trying to clean up the code, modularize it, and write tests and documentation.

General backstory: I had been playing around a lot with TileMill and Mapnik and trying to programmatically generate map tiles; at CfA we have a lot of big, dynamic data and I was trying to set up an automated tile renderer. Then I came across a Tom Carden project where he was use Node-Canvas to render tiles... and then I discovered a node-canvas module that would run on Heroku... and by that point I was in love with the idea of a low-dependency (compared to mapnik) on-the-fly tile rendering implementation.

From there, I wanted to see how close I could get to a full-blown TileJSON implementation. I had my coworker Rob Brackett write me a Javascript UTFGrid implementation and I hooked that up to the tile rasterizer. And bam. It's clunky as hell, and sort've slow (it's rendering an entire shapefile then cropping it down for every tile rather than spatially indexing the features), but I think it has potential. 

I think the next step (in addition to cleanup and documentation) is loading up some OSM metro data and actually seeing how the performance compares to Mapnik. Also, while I can't foresee implementing something like Cascadenik, node-canvas gives you direct access to the graphics renderer and it might be useful for creating boutique maps with graphical flourishes that Mapnik hasn't implemented... and of course for creating layers with dynamic data.

Let me know if you have any specific questions or ideas you'd like me to try to implement or use as demos. Thanks for the interest!

</blockquote>

**Alex**

Alex Yule, another Code for America Fellow, and an actual experienced cartographer, was also interested. Alex joined Rob and my presentation proposal at NACIS. This was our abstract:

> **NodeTiles: Joyful Map Tile Rendering with Node.js**
> Mapnik has become the de facto open-source standard for rendering map tiles. While Mapnik is extremely powerful, it can be difficult to set up and deploy. We present NodeTiles, a lightweight, JavaScript-based, open-source map tile renderer that is easy to deploy, use, and extend. Built to support applications with dynamic data, NodeTiles offers an accessible and cloud-friendly alternative to Mapnik. While still in early-stage development, features on the road-map include styling with the CSS-based Carto language for compatibility with MapBox TileMill, UTFGrid generation for client-side interactivity, and data adaptors for PostGIS and Shapefiles.

**NACIS**

The NACIS (North American Cartographic Information Society) conference was October 17-19, 2012 in Portland, Oregon. Alex and Rob and I had gotten an AirBnB and I mostly remember us doing a lot of last-minute implementing. Alex built a really nice Postgres Adapter plugin, and Rob was reimplementing Cascadenik ("CSS for Maps) somewhere between Javascript and Cairo; I remember a deep-dive into blitting. We presented at a breakout called "Slippy Maps".
 
I remember riding BART back from the airport when we arrived back in San Francisco. I was talking with a maybe-a-big-deal person from the maptech community, and they asked me something pointed like "But how much did you *really* contribute to Nodetiles?" I said, and truly believe "It was a team effort" and then it got really quiet. In retrospect that was probably a job interview, and also fuck that, it was a team effort.

**That's it**

The Code for America Fellowship was ending and interviewing as an inexperienced engineer is freaking hard. So I mostly put down Nodetiles. And also:

- Going from something that’s a tech demo to something usable by outsiders is hard.
- The sheer difficulty of spatial work. That dumb Nodetiles logo took me hours just to get the tooling together to just like, draw straight lines on a globe to say "Nodetiles"
- I leaned into some questionable architectural decisions to make it more Javascripty, splitting up the front and backends, and modularizing all the different pieces into their own packages. In hindsight that was a lot of valueless work that only introduced friction into building the tool. That's on me.
- Given that this is an email-based retrospective, I will admit I found some emails from kinda big deals like Stamen that I didn't respond to. I dunno why I didn't respond; probably burnout. If that was you, I hope you didn't take my nonresponse personally.

Nodetiles is still up on GitHub. If you can get nodecanvas linking to cairo (memories of successfully installing nodecanvas and cairo still feels like a fever dream), Nodetiles is really cool. Maybe you'll do something neat with it. 
