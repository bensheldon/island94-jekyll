require 'capybara/rspec'
require 'rack/file'

RSpec.configure do |config|
  config.include Capybara::DSL

  config.before :suite do
    built_dir = File.join(File.dirname(__FILE__), '../_site')
    Capybara.app = Rack::Directory.new(built_dir)
  end
end
