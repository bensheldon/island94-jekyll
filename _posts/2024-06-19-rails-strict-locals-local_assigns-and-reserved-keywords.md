---
title: "Rails Strict Locals, undefined `local_assigns`, and reserved keywords"
date: 2024-06-19 15:21 PDT
published: true
tags: []
---

_Huge thank you to Vojta Drbohlav in the [Rails Performance Slack](https://www.railsspeed.com/) for helping me figure this out! 🙇_

Things I learned today about a new-to-me Ruby on Rails feature:

- Rail 7.1 added a feature called ["Strict Locals"](https://blog.kiprosh.com/allow-template-to-set-strict-locals/) that uses a magic comment in ERB templates to declare required and optional local variables. It looks like this: `<%# locals: (shirts:, class: nil) %>` which in this example means when rendering the partial, it must be provided a `shirts` parameter and optional `class` parameter. It's a nice feature to have ERB templates act more like callable functions with explicit signatures.
- When using Rails Strict Locals, the `local_assigns` variable [_is not defined_](https://github.com/rails/rails/blob/4bb73233413f30fd7217bd7f08af44963f5832b1/actionview/lib/action_view/template.rb#L439-L444). You can't use `local_assigns`. You'll see an error that looks like `ActionView::Template::Error (undefined local variable or method 'local_assigns' for an instance of #<Class:0x0000000130536cc8>)`.
- This is a problem if your template has locals that are also Ruby reserved keywords like `class` or `if`, which can be accessed with `local_assigns[:class]` _unless you start using Strict Locals_.
- To access those local variables named with reserved keywords in your ERB template when using Strict Locals, you can use `binding.local_variable_get(:the_variable_name)` e.g. `binding.local_variable_get(:class)` or `binding.local_variable_get(:if)`.
