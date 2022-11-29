require 'bundler/setup'
require 'capybara/rspec'
require 'capybara/cuprite'
require 'lanyon'
require 'pry'
require 'webrick'

RSpec.configure do |config|
  config.include Capybara::DSL

  Capybara.register_driver(:cuprite) do |app|
    Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], inspector: ENV['INSPECTOR'])
  end

  Capybara.server = :webrick
  Capybara.default_driver = :rack_test
  Capybara.javascript_driver = :cuprite
  Capybara.app = Lanyon.application(skip_build: ENV.fetch('JEKYLL_SKIP_BUILD', true))
end
