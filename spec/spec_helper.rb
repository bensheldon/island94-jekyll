require 'bundler/setup'
require 'capybara/rspec'
require 'pry'
require 'rack/jekyll'

# https://stackoverflow.com/a/52507221/241735
jekyll = Rack::Jekyll.new(force_build: ENV.fetch('JEKYLL_FORCE_BUILD', false), auto: true)
sleep 0.1 while jekyll.compiling?

Capybara.app = jekyll
RSpec.configure do |config|
  config.include Capybara::DSL
end
