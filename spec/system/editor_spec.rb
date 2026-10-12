# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Editor", :fake_claude do
  let(:filename) { "2026-01-01-editor-system-spec.md" }
  let(:document_path) { "/editor/documents/2026-01-01-editor-system-spec" }

  it "creates a new unpublished post file" do
    visit "/editor"
    fill_in "title", with: "Editor Spec Brand New Post"
    click_on "New post"

    path = Rails.root.glob("_posts/*-editor-spec-brand-new-post.md").first
    expect(path).to be_present
    expect(page).to have_field("document[title]", with: "Editor Spec Brand New Post")
    expect(Post.from_file(path)).not_to be_published
  ensure
    FileUtils.rm_f(path) if path
    Post.reset
  end

  it "saves edits to the file as Markdown and records revisions", :js do
    with_temporary_post(filename: filename, body: "Original text.") do |post|
      visit document_path
      editor = find("lexxy-editor [contenteditable='true']")
      editor.click
      editor.send_keys([:command, "a"], :backspace) # select all
      editor.send_keys("Edited ")
      editor.send_keys([:command, "b"], "bold", [:command, "b"], " text.")
      click_on "Save revision"

      expect(page).to have_text "Saved _posts/#{filename}"
      expect(Post.from_file(post.filepath).body.strip).to eq "Edited **bold** text."

      click_on "History"
      expect(page).to have_text("Saved").and have_text("Opened")

      within(".list-group-item", text: "Opened") { click_on "Restore" }
      expect(page).to have_text "Restored revision"
      expect(File.read(post.filepath)).to include "Original text."
    end
  end

  it "runs an AI review in the background, then resolves and ignores findings", :js do
    with_temporary_post(filename: filename, body: "This is very really actually good.") do
      visit document_path
      select "Spelling & typos", from: "pass_id"
      click_on "Review"
      expect(page).to have_text("1 finding", wait: 10)
      expect(page).to have_text("~$0.12 API-equivalent")
      select "Grammar", from: "pass_id"
      click_on "Review"
      expect(page).to have_css(".commentary-card", count: 2, wait: 10)

      within(".commentary-card", text: "Spelling & typos") do
        expect(page).to have_text "Three empty intensifiers stacked together."
        expect(page).to have_text "Suggestion: very"
        click_on "Resolve"
      end
      expect(page).to have_css(".commentary-card.is-resolved", text: "Resolved")

      within(".commentary-card", text: "Grammar") { click_on "Ignore" }
      expect(page).to have_css(".commentary-card.is-ignored", text: "Ignored")
      expect(Editor::Highlight.all.map(&:status)).to contain_exactly("resolved", "ignored")

      within(".commentary-card", text: "Grammar") { click_on "Reopen" }
      expect(page).to have_css(".commentary-card.is-open", text: "Grammar")

      # Re-running a check replaces its earlier findings, including resolved ones
      select "Spelling & typos", from: "pass_id"
      click_on "Review"
      expect(page).to have_no_css(".commentary-card.is-resolved", wait: 10)
      expect(page).to have_css(".commentary-card.is-open", count: 2, wait: 10)
      expect(Editor::Highlight.all.map(&:status)).to eq %w[open open]
    end
  end

  it "accepts a suggestion by editing the post", :js do
    with_temporary_post(filename: filename, body: "I go to the **store** and buyed apples.") do |post|
      Editor::Highlight.create!(document_id: "2026-01-01-editor-system-spec", quote: "buyed", original_quote: "buyed", suggestion: "bought",
                                color: "pink", pass_name: "Spelling & typos", comment: "Misspelled.")
      visit document_path
      expect(page).to have_css(".hl-squiggle", visible: :all)

      within(".commentary-card") { click_on "Accept" }

      expect(page).to have_css(".commentary-card.is-accepted", text: "Accepted")
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      expect(Post.from_file(post.filepath).body.strip).to eq "I go to the **store** and bought apples."
      expect(Editor::Highlight.all.map(&:status)).to eq ["accepted"]
    end
  end

  it "keeps formatting when accepting a suggestion", :js do
    with_temporary_post(filename: filename, body: "Then I go to the **store** and buyed [some](https://example.com) _fresh_ apples.") do |post|
      quote = "I go to the store and buyed some fresh apples"
      Editor::Highlight.create!(document_id: "2026-01-01-editor-system-spec", quote: quote, original_quote: quote,
                                suggestion: "I went to the store and bought some fresh apples", color: "blue", pass_name: "Grammar", comment: "Tense.")
      visit document_path
      expect(page).to have_css(".hl-squiggle", visible: :all)

      within(".commentary-card") { click_on "Accept" }

      expect(page).to have_css(".commentary-card.is-accepted")
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      expect(Post.from_file(post.filepath).body.strip).to eq "Then I went to the **store** and bought [some](https://example.com) _fresh_ apples."
    end
  end

  it "accepts overlapping suggestions one after another", :js do
    with_temporary_post(filename: filename, body: "Yesterday I go to the the store.") do |post|
      id = "2026-01-01-editor-system-spec"
      Editor::Highlight.create!(document_id: id, quote: "the the store", original_quote: "the the store", suggestion: "the store",
                                color: "pink", pass_name: "Spelling & typos", comment: "Doubled word.")
      Editor::Highlight.create!(document_id: id, quote: "Yesterday I go to the the store", original_quote: "Yesterday I go to the the store",
                                suggestion: "Yesterday I went to the the store", color: "blue", pass_name: "Tense & voice consistency", comment: "Tense shift.")
      visit document_path
      expect(page).to have_css(".hl-squiggle", count: 2, visible: :all)

      within(".commentary-card", text: "Spelling & typos") { click_on "Accept" }
      expect(page).to have_css(".commentary-card.is-accepted", text: "Spelling & typos")
      within(".commentary-card", text: "Tense & voice consistency") { click_on "Accept" }
      expect(page).to have_css(".commentary-card.is-accepted", count: 2)

      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      expect(Post.from_file(post.filepath).body.strip).to eq "Yesterday I went to the store."
    end
  end

  it "keeps a finding attached to its text as it is edited", :js do
    with_temporary_post(filename: filename, body: "First sentence. This is very really actually good. Last sentence.") do
      Editor::Highlight.create!(document_id: "2026-01-01-editor-system-spec", quote: "very really actually", original_quote: "very really actually",
                                color: "pink", pass_name: "Concision", comment: "Empty intensifiers.")
      visit document_path
      expect(page).to have_css(".hl-squiggle", visible: :all)

      # Delete "really " from inside the flagged span
      page.execute_script(<<~JS)
        const walker = document.createTreeWalker(document.querySelector("lexxy-editor [contenteditable='true']"), NodeFilter.SHOW_TEXT)
        const node = walker.nextNode()
        const start = node.nodeValue.indexOf("really ")
        const range = document.createRange()
        range.setStart(node, start)
        range.setEnd(node, start + "really ".length)
        window.getSelection().removeAllRanges()
        window.getSelection().addRange(range)
      JS
      find("lexxy-editor [contenteditable='true']").send_keys(:backspace)

      within(".commentary-card") { expect(page).to have_css(".commentary-quote", text: "very actually") }
      expect(page).to have_no_css(".commentary-card.is-stale")
      page.document.synchronize(5) do
        raise Capybara::ExpectationNotMet, "quote not saved" unless Editor::Highlight.all.first.quote == "very actually" # rubocop:disable Rails/RedundantActiveRecordAllMethod
      end

      # Replace the whole flagged span, then type right after it
      select_text = lambda do |text|
        page.execute_script(<<~JS)
          const walker = document.createTreeWalker(document.querySelector("lexxy-editor [contenteditable='true']"), NodeFilter.SHOW_TEXT)
          const node = walker.nextNode()
          const start = node.nodeValue.indexOf(#{text.to_json})
          const range = document.createRange()
          range.setStart(node, start)
          range.setEnd(node, start + #{text.length})
          window.getSelection().removeAllRanges()
          window.getSelection().addRange(range)
        JS
      end
      select_text.call("very actually")
      find("lexxy-editor [contenteditable='true']").send_keys("quite")
      within(".commentary-card") { expect(page).to have_css(".commentary-quote", text: /\Aquite\z/) }

      select_text.call(" good")
      find("lexxy-editor [contenteditable='true']").send_keys(" fine")
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      within(".commentary-card") { expect(page).to have_css(".commentary-quote", text: /\Aquite\z/) }
    end
  end

  it "keeps reviews and highlights across server restarts" do
    with_temporary_post(filename: filename, body: "Some text.") do
      Editor::Highlight.create!(document_id: "2026-01-01-editor-system-spec", quote: "Some", color: "blue", comment: "A finding.")
      Editor::Review.create!(document_id: "2026-01-01-editor-system-spec", pass_ids: [1], pass_name: "Grammar", color: "orange", status: "running")
      Editor::Store.instance_variable_set(:@_data, nil) # simulate a restart

      visit document_path
      expect(page).to have_css(".commentary-card", text: "Some")
      within("#review_panel") { expect(page).to have_text "Interrupted" }
    end
  end

  it "straightens quotes throughout the post when saving a revision" do
    with_temporary_post(filename: filename, title: "It’s “titled”", body: "It’s “untouched.”\n\nAnother paragraph.") do |post|
      visit document_path
      click_on "Save revision"

      expect(page).to have_text "Saved _posts/#{filename}"
      saved = Post.from_file(post.filepath)
      expect(saved.title).to eq %(It's "titled")
      expect(saved.body.strip).to eq %(It's "untouched."\n\nAnother paragraph.)
    end
  end

  it "saves a revision with Ctrl-S or ⌘S", :js do
    with_temporary_post(filename: filename, body: "Start.") do |post|
      visit document_path
      editor = find("lexxy-editor [contenteditable='true']")
      editor.click
      editor.send_keys(:end, " More.")
      editor.send_keys([:control, "s"])

      expect(page).to have_text "Saved _posts/#{filename}"
      expect(Post.from_file(post.filepath).body.strip).to eq "Start. More."
      expect(Editor::Revision.all.map(&:label)).to include("Saved")
    end
  end

  it "replaces curly quotes as they're typed", :js do
    with_temporary_post(filename: filename, body: "Start.") do |post|
      visit document_path
      editor = find("lexxy-editor [contenteditable='true']")
      editor.click
      editor.send_keys(:end, " It’s “typed.”")
      expect(editor).to have_text(%(It's "typed."))
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      expect(Post.from_file(post.filepath).body.strip).to eq %(Start. It's "typed.")
    end
  end

  it "keeps straight quotes when editing", :js do
    with_temporary_post(filename: filename, body: %(It's "quoted" -- ok...\n\nSecond.)) do |post|
      visit document_path
      editor = find("lexxy-editor [contenteditable='true']")
      editor.click
      editor.send_keys([:command, :down], " More.")
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)

      expect(Post.from_file(post.filepath).body).to eq %(It's "quoted" -- ok...\n\nSecond. More.)
    end
  end

  it "autosaves edits", :js do
    with_temporary_post(filename: filename, body: "The quick brown fox.") do |post|
      visit document_path
      editor = find("lexxy-editor [contenteditable='true']")
      editor.click
      editor.send_keys(:end, " It jumps.")
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      expect(File.read(post.filepath)).to include "The quick brown fox. It jumps."
    end
  end
end
