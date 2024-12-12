require_relative "boot"

require "rails"
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Island94
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    self.reloaders << ActiveSupport::FileUpdateChecker.new([], {
      "_posts" => ["md", "markdown"],
      "_bookmarks" => ["md", "markdown"],
    }) do
      Rails.application.reload_routes!
    end

    config.middleware.use Rack::Static,
      urls: ["/uploads"],
      root: Rails.root.to_s,
      header_rules: [
        [:all, { "Cache-Control" => "public, max-age=15552000" }]
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
