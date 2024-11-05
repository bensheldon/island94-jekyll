---
title: Is SecureRandom.choose the wrong name for generating randomized strings with Ruby?
date: 2021-05-27 08:37 PDT
published: true
tags:
---

I frequently need to generate a short, random string:

- I need a non-numeric, non-enumerable url ID. e.g. `https://example.com/resources/TOKEN`
- I need to generate a short, human-readable random activation token and I don’t want it to contain similar-looking characters like `1I` or `O0` 
- I want to do something fun with strings of emojis.

 I’ve been copy-pasting this snippet around for years:

```ruby
def random_string(alphabet:, length:)
  Array.new(length) { alphabet.chars[rand(alphabet.chars.size)] }.join
end

random_string(alphabet: "AaBbCc123", length: 7) 
# => "C113A11", "Abcc3B2", "33cabbC", etc.

random_string(alphabet: "😀😍🙃🤪😎", length: 3)
# => "😍😀😎", "😀🤪🤪", "🙃😎😀", etc.
```

The gems [`friendly_id`](https://github.com/norman/friendly_id) and [`uniquify`](https://github.com/ryanb/uniquify) can do this too.

There was recently a discussion on [Ruby on Rails Link Slack](https://www.rubyonrails.link/) about generating random strings, and I went looking to see if there was a better implementation.

I found [`SecureRandom.choose`](https://github.com/ruby/ruby/blob/029169bc5b45d8ec783c19eaf713395b7983d16a/lib/securerandom.rb#L247-L291), which is built into the Ruby standard library, and as part of the `SecureRandom` module, should be fairly trustworthy. Looks perfect:

```ruby
# SecureRandom.choose generates a string that randomly draws from a source array of characters.
#
# The argument _source_ specifies the array of characters from which to generate the string.
# The argument _n_ specifies the length, in characters, of the string to be generated.
#
# The result may contain whatever characters are in the source array.
#
#   require 'securerandom'
#
#   SecureRandom.choose([*'l'..'r'], 16) #=> "lmrqpoonmmlqlron"
#   SecureRandom.choose([*'0'..'9'], 5)  #=> "27309"
```

...but there is a problem: `SecureRandom.choose` is a private method. The `choose` method is used to implement the public `SecureRandom.alphanumeric` method, but is not itself exposed publicly. I went back to the initial [feature request](https://bugs.ruby-lang.org/issues/10849) and found the reason:

> I feel the method name, SecureRandom.choose, doesn’t represent the behavior well.

Fair enough. Until the name is figured out, I’ll still be using it:

```ruby
require 'securerandom'

SecureRandom.send :choose, "😀😍🙃🤪😎".chars, 3
# => "😍😎😍"
```


