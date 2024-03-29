---
title: "Service Object Objects in Ruby"
date: 2023-02-14 08:18 PST
published: true
tags: [Ruby]
---

For anyone that follows me on social media, I'll sometimes get into a [Coplien](https://deprogrammaticaipsum.com/james-coplien/)-esque funk of "I don't wanna write Classes. I want to write _Objects_!". I don't want to negotiate an industrial-relations policy for instances of Person in the current scope. I want to imagine the joy and misery Alice and Bob will experience working together right now.

I was thinking of that recently when [commenting on Reddit](https://www.reddit.com/r/ruby/comments/10sooyr/comment/j74j5qw/?utm_source=reddit&utm_medium=web2x&context=3) about Caleb Hearth's ["The Decree Design Pattern"](https://calebhearth.com/decree). Which ended up in the superset of these two thoughts:

- heck yeah! if it's globally distinct it should be globally referenceable
- oh, oh no, I don't like looking at _that_ particular Ruby code

This was my comment to try to personally come to terms with those thoughts, iteratively:

```ruby
# a consistent callable
my_decree = -> { do_something }

# ok, but globally scoped
MY_DECREE = -> { do_something }

# ok, but without the shouty all-caps
module MyDecree
  def self.call 
    do_something 
  end 
end

# ok, but what about when it gets really complex
class MyDecree 
  def self.call(variable)
    new(variable).call 
  end
  
  def new(variable)
    @variable = variable
  end

  def call
    do_something
    do_something_else(@variable)
    do_even_more
  end

  def do_even_more
    # something really complicated....
  end
end
```

From the outside, _object_ perspective, these are all have the same interchangeable interface (`.call`), and except for the first one, accessible everywhere. That's great, from my perspective! Though I guess it's a pretty short blog post to say:

- Decrees are globally discrete and call-able objects
- The implementation is up to you!

Unfortunately, the moment the internals come into play, it gets messy. But I don't think that should take away from the external perspective.





