---
link: http://docs.jquery.com/Plugins/Authoring
date: 2011-10-16 14:21 UTC
published: true
title: Plugins/Authoring - jQuery JavaScript Library
tags:
- javascript
- webdevelopment
---

For more complex and customizable plugins that provide many options, it's a best practice to have default settings that can get extended (using $.extend) when the plugin is invoked. So instead of calling a plugin with a large number of arguments, you can call it with one argument which is an object literal of the settings you would like to override. Here's how you do it.
