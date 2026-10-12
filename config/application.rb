# frozen_string_literal: true
require_relative "boot"

require "rails"
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "middleware/redirect_to_meta_refresh"

# The writing tool at /editor is for local use only and is never part of the published site.
require_relative "../engines/editor/lib/editor" if Rails.env.local?

module Island94
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # `to_time` will always preserve the full timezone rather than offset of the receiver in Rails 8.1.
    config.active_support.to_time_preserves_timezone = :zone

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.secret_key_base = "0"

    config.middleware.insert_before 0, RedirectToMetaRefresh
    config.middleware.use Rack::Static,
                          urls: ["/uploads"],
                          root: Rails.root.to_s,
                          header_rules: [
                            [:all, { "Cache-Control" => "public, max-age=15552000" }],
                          ]

    config.default_url_options = {}

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
