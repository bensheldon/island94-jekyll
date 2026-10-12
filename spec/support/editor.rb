# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    Editor::Store.reset!
  end
end
