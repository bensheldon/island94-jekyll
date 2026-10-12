# frozen_string_literal: true
require_relative "../rails_helper"

RSpec.describe Bookmark do
  describe '.load_all' do
    it 'loads all bookmarks from _bookmarks directory' do
      result = described_class.all

      expect(result.size).to be > 1
      expect(result.first).to be_a(described_class)
    end
  end

  describe '#published?' do
    it 'is true when the frontmatter has no published key' do
      bookmark = described_class.new(frontmatter: {})
      expect(bookmark.published?).to be(true)
    end

    it 'is true when published is explicitly true' do
      bookmark = described_class.new(frontmatter: { "published" => true })
      expect(bookmark.published?).to be(true)
    end

    it 'is false when published is explicitly false' do
      bookmark = described_class.new(frontmatter: { "published" => false })
      expect(bookmark.published?).to be(false)
    end
  end

  describe '.published' do
    it 'excludes unpublished bookmarks' do
      published_bookmark = described_class.new(filepath: "#{Rails.root}/_bookmarks/2024/2024-01-01-published.md", frontmatter: { "published" => true })
      unpublished_bookmark = described_class.new(filepath: "#{Rails.root}/_bookmarks/2024/2024-01-01-unpublished.md", frontmatter: { "published" => false })
      allow(described_class).to receive(:all).and_return([published_bookmark, unpublished_bookmark])

      expect(described_class.published).to eq([published_bookmark])
    end
  end

  describe '.create!' do
    let(:date) { Time.zone.parse("2026-01-01 12:00") }
    let(:path) { Rails.root.join("_bookmarks", "2026", "2026-01-01-example-com-test-post.md") }

    after do
      FileUtils.rm_f(path)
      described_class.reset
    end

    it 'writes a new bookmark file to disk' do
      bookmark = described_class.create!(link: "https://example.com/test-post", title: "Test Post", tags: ["ruby"], notes: "First notes.", date: date)

      expect(File.exist?(path)).to be(true)
      expect(bookmark.filepath).to eq(path.to_s)
      expect(bookmark.link).to eq("https://example.com/test-post")
      expect(bookmark.title).to eq("Test Post")
      expect(bookmark.tags).to eq(["ruby"])
      expect(bookmark.body).to include("First notes.")
    end

    it 'appends new notes below a horizontal rule when a bookmark for the same link/date already exists' do
      first = described_class.create!(link: "https://example.com/test-post", title: "Test Post", notes: "First notes.", date: date)
      second = described_class.create!(link: "https://example.com/test-post", notes: "Second notes.", date: date)

      expect(second.filepath).to eq(first.filepath)
      expect(second.title).to eq("Test Post") # original frontmatter is preserved, not overwritten
      expect(second.body).to include("---")
      expect(second.body.index("First notes.")).to be < second.body.index("Second notes.")
    end
  end
end
