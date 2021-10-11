---
title: TIL: Detecting block returns in Ruby 
date: 2021-10-11 12:01 PDT
published: true
tags:
---

I was doing some research on introspecting Ruby on Rails database transactions for a [Reddit thread](https://www.reddit.com/r/ruby/comments/q54515/comment/hg9dzdc/?utm_source=reddit&utm_medium=web2x&context=3), and came across this [Rails PR](https://github.com/rails/rails/pull/29333) that had some new Ruby behavior for me: detecting an early `return` from a block.

Some background: A Ruby language feature, that can frequently surprise people, is that using `return` within a Ruby block will return not only from the block itself, but also from the block's caller too. Using `next` is really the only truly safe way to interrupt a block early; even `break` can be troublesome if the block is called by an enumerator. Also, `next` can take a return value too, just like `return` e.g. `next my_value`.  

I found the Rails PR interesting, because it has a method for detecting and warning on an early return. Here's a simplified example:

```ruby
def some_method(&block)
  block.call
  completed = true # won't be called if the block returns early
ensure
  if completed
    puts "ok"
  else
    puts "returned early"
  end
end

some_method { return } # => "returned early"
some_method { next } # => "ok"
````

This works because the methods `ensure` block will always be called, even if `#some_method` returns early. That was a novel implementation for me.


