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

  it "proofreads as you type and accepts a suggestion", :js do
    with_temporary_post(filename: filename, body: "I go to the **store** and recieve teh apples.") do |post|
      visit document_path

      card = find(".commentary-card", text: "teh", wait: 10)
      expect(page).to have_css(".hl-squiggle", visible: :all)
      card.first(".suggestion-button", text: "the").click

      expect(page).to have_no_css(".commentary-card[data-key$=':teh']", wait: 10)
      expect(page).to have_css("[data-autosave-target='status']", text: "Saved", wait: 5)
      expect(Post.from_file(post.filepath).body.strip).to eq "I go to the **store** and recieve the apples."
    end
  end

  it "stores findings on the server and keeps ignored ones ignored", :js do
    with_temporary_post(filename: filename, body: "This is a test of teh editor.") do
      visit document_path

      within(".commentary-card", text: "teh", wait: 10) { click_on "Ignore" }
      expect(page).to have_no_css(".commentary-card", text: "teh")
      expect(page).to have_text "1 ignored finding"
      expect(Editor::Finding.all.find { |finding| finding.problem == "teh" }).to be_ignored

      visit document_path
      expect(page).to have_text("1 ignored finding", wait: 10)
      expect(page).to have_no_css(".commentary-card", text: "teh")

      click_on "Show again"
      expect(page).to have_css(".commentary-card", text: "teh")
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
