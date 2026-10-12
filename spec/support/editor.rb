# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    Editor::Store.reset!
  end

  config.around(:each, :fake_claude) do |example|
    original = ENV.fetch("CLAUDE_BIN", nil)
    ENV["CLAUDE_BIN"] = Rails.root.join("spec/support/editor/fake_claude").to_s
    example.run
  ensure
    ENV["CLAUDE_BIN"] = original
  end
end
