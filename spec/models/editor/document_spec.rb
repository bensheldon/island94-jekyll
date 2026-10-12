# frozen_string_literal: true
require "rails_helper"

RSpec.describe Editor::Document do
  let(:filename) { "2026-01-01-editor-document-spec.md" }

  it "round-trips a post file without changing it" do
    with_temporary_post(filename: filename, body: "Hello *world*.\n", date: "2026-01-01 12:00 UTC") do |post|
      original = File.read(post.filepath)
      document = described_class.find("2026-01-01-editor-document-spec")

      expect(document.title).to eq "Temporary Test Post"
      expect(document.body).to eq "Hello *world*.\n"
      expect(document.content).to eq original
    end
  end

  it "writes the title, front matter, and body back to the file" do
    with_temporary_post(filename: filename, body: "Before") do |post|
      document = described_class.find("2026-01-01-editor-document-spec")
      expect(document.update(title: "New Title", body: "After\r\nwards")).to be true

      reloaded = Post.from_file(post.filepath)
      expect(reloaded.title).to eq "New Title"
      expect(reloaded.tags).to eq []
      expect(reloaded.body).to eq "After\nwards"
    end
  end

  it "refuses to write invalid front matter" do
    with_temporary_post(filename: filename, body: "Body") do |post|
      original = File.read(post.filepath)
      document = described_class.find("2026-01-01-editor-document-spec")

      expect(document.update(front_matter: "title: [unclosed")).to be false
      expect(document.errors[:front_matter].first).to include "is not valid YAML"
      expect(File.read(post.filepath)).to eq original
    end
  end
end
