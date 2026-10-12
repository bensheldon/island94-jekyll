# frozen_string_literal: true
require "rails_helper"

# Runs every post through the real Lexxy editor and back to Markdown, writing
# the posts that changed to tmp/editor-roundtrip/ for inspection. Opt-in:
#
#   EDITOR_ROUNDTRIP=1 bin/rspec spec/system/editor_roundtrip_spec.rb
RSpec.describe "Editor Markdown round-trip", :js do
  before { skip "set EDITOR_ROUNDTRIP=1 to run" unless ENV["EDITOR_ROUNDTRIP"] }

  it "round-trips all posts through Lexxy" do
    output = Rails.root.join("tmp/editor-roundtrip")
    FileUtils.rm_rf(output)
    FileUtils.mkdir_p(output)

    with_temporary_post(filename: "2026-01-01-editor-roundtrip.md", body: "Round-trip") do
      visit "/editor/documents/2026-01-01-editor-roundtrip"
      find("lexxy-editor [contenteditable='true']")

      documents = Editor::Document.all.reject { |document| document.id == "2026-01-01-editor-roundtrip" }
      changed = documents.reject do |document|
        html = page.evaluate_script(<<~JS)
          (() => {
            const editor = document.querySelector("lexxy-editor")
            editor.value = #{document.body_html.to_json}
            return editor.value
          })()
        JS
        markdown = Editor::Markdown.to_markdown(html, original: document.body)
        next true if markdown == document.body.strip

        File.write(output.join("#{document.id}.orig.md"), "#{document.body.strip}\n")
        File.write(output.join("#{document.id}.new.md"), "#{markdown}\n")
        false
      end

      # 81 posts currently change, mostly in ways that render identically.
      expect(changed.size).to be <= 81, "#{changed.size} of #{documents.size} posts changed; see #{output}"
    end
  end
end
