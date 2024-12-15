require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.assets.compile = true

  config.force_ssl = false

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
end
