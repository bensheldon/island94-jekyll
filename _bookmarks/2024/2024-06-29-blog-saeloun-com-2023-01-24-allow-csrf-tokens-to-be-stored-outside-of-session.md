---
link: https://blog.saeloun.com/2023/01/24/allow-csrf-tokens-to-be-stored-outside-of-session/
date: 2024-06-29 20:00 UTC
published: true
title: Secure CSRF Token Storage in Rails 7 using Encrypted Cookies
tags: []
---

> To use this feature, we need to set config.action_controller.use_custom_csrf_token to a lambda that returns the token to be used for the request. The lambda will then be called with the request object as an argument.
