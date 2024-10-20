---
title: Adding class to Wordpress linked images
date: '2011-01-23'
tags:
- code
- css
- php
- theming
- wordpress
wp:post_type: post
redirect_from:
- 2011/01/adding-class-to-wordpress-linked-images/
- "?p=2425"
---

An [enduring issue](http://wordpress.org/support/topic/how-can-i-set-the-class-of-anchors) with linked images ( `<a href=""><img src="" /></a>` ), is targeting the anchor link for theming—especially for disabling borders and highlighting that look great on text links but odd for images. CSS doesn't have a parent selector ( `a > img:parent` ), and javascript feels like overkill. The simple solution is to add a `class` to the parent anchor (`<a href="" class="img">)`, but that can get repetitive, especially when Wordpress is supposed to automate those sorts of things.

Adding the following code to your Wordpress theme's `functions.php` file will automatically add a class to the anchor link when you insert linked images through Wordpress's Media Library interface. It won't fix posts you've already written, but should make things better moving forward.


```php
/**
 * Attach a class to linked images' parent anchors
 * e.g. a img => a.img img
 */
function give_linked_images_class($html, $id, $caption, $title, $align, $url, $size, $alt = '' ) {
  // Separate classes with spaces, e.g. 'img image-link'
  $classes = 'img';

  // check if there are already classes assigned to the anchor
  if ( preg_match('/<a.*? class=".*?">/', $html) ) {
    $html = preg_replace('/(<a.*? class=".*?)(".\?>)/', '$1 ' . $classes . '$2', $html);
  }
  else {
    $html = preg_replace('/(<a.*?)>/', '$1 class="' . $classes . '" >', $html);
  }

  return $html;
}

add_filter('image_send_to_editor', 'give_linked_images_class', 10, 8);
```

The if/else could probably be done with a single regular expression, but I'm not _that_ smart.
