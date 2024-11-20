---
title: "Keep your secrets.yml in Rails 7.2+"
date: 2024-11-19 16:13 PST
published: true
tags: []
---

Ruby on [Rails v7.1 deprecated and v7.2 removed](https://www.shakacode.com/blog/rails-7-1-removes-secret-setup-command-and-deprecates-secret-show-edit-commands/) support for `Rails.application.secrets` and `config/secrets.yml` in favor of Encrypted Credentials. You don't have to go along with that! 

It's extremely simple to reimplement the same behavior using [`config_for`](https://guides.rubyonrails.org/configuring.html#custom-configuration) and the knowledge that methods defined in `application.rb` show as methods on `Rails.application`:

```ruby
# config/application.rb

module ExampleApp
  class Application < Rails::Application
    # ....
    config.secrets = config_for(:secrets) # loads from config/secrets.yml
    config.secret_key_base = config.secrets[:secret_key_base]

    def secrets
      config.secrets
    end
  end
end
```

That is all you need to continue using a `secrets.yml` file that probably looks like this:

```yaml
# config/secrets.yml

defaults: &defaults
  default_host: <%= ENV.fetch('DEFAULT_HOST', 'localhost:3000') %>
  twilio_api_key: <%= ENV.fetch('TWILIO_API_KEY', 'fake') %>
  mailgun_secret: <%= ENV.fetch('MAILGUN_SECRET', 'fake') %>

development:
  <<: *defaults
  secret_key_base: 79c6d24d26e856bc2549766552ff7b542f54897b932717391bf705e35cf028c851d5bdf96f381dc41472839fcdc8a1221ff04eb4c8c5fbef62a6d22747f079d7

test:
  <<: *defaults
  secret_key_base: 0b3abfc0c362bab4dd6d0a28fcfea3f52f076f8d421106ec6a7ebe831ab9e4dc010a61d49e41a45f8f49e9fc85dd8e5bf3a53ce7a3925afa78e05b078b31c2a5

# Do not keep production secrets in the repository,
# instead read values from the environment.
production:
  <<: *defaults
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  default_host: <%= ENV['DEFAULT_HOST'] || (ENV['HEROKU_APP_NAME'] ? "#{ENV['HEROKU_APP_NAME']}.herokuapp.com": nil) %>
```

**Note:** This only works for `secrets.yml` not `secrets.enc.yml` which was called "Encrypted Secrets." If you're using "Encrypted Secrets" then you should definitely move over to the Encrypted Credentials feature.
