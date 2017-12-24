require 'bundler/setup'
require 'capybara/rspec'
require 'pry'
require 'rack/jekyll'

Capybara.app = Rack::Jekyll.new(force_build: false)

RSpec.configure do |config|
  config.include Capybara::DSL
end
