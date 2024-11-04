# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# TODO: Unduplicate this from spec_helper.rb
# Necessary to be here because 'rspec/rails' will override these settings

require 'capybara/rspec'
require 'capybara/cuprite'
require 'lanyon'
require 'webrick'

RSpec.configure do |config|
  config.include Capybara::DSL

  Capybara.register_driver(:cuprite) do |app|
    Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], process_timeout: 30, inspector: ENV['INSPECTOR'])
  end

  Capybara.server = :webrick
  Capybara.default_driver = :rack_test
  Capybara.javascript_driver = :cuprite
  Capybara.app = Lanyon.application(skip_build: ENV.fetch('JEKYLL_SKIP_BUILD', true))
end
