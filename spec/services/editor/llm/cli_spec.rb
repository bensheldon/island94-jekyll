# frozen_string_literal: true
require "rails_helper"

RSpec.describe Editor::Llm::Cli do
  it "kills a CLI that doesn't finish in time" do
    hung = Rails.root.join("tmp/editor-hung-claude")
    File.write(hung, "#!/bin/sh\nsleep 30\n")
    File.chmod(0o755, hung)
    cli = described_class.new(binary: hung.to_s, timeout: 0.5)

    started = Time.current
    expect { cli.structured("prompt", system: "system", schema: {}) }.to raise_error(described_class::Error, /timed out/)
    expect(Time.current - started).to be < 5
  ensure
    FileUtils.rm_f(hung)
  end
end
