# frozen_string_literal: true
require_relative "../rails_helper"

RSpec.describe Post do
  describe '.load_all' do
    it 'loads all posts from _posts directory' do
      result = described_class.all

      expect(result.size).to be > 1
      expect(result.first).to be_a(described_class)
      expect(result.first.title).to eq("Pool Soup")
    end
  end

  describe '#tags' do
    it 'returns an empty array when tags is absent' do
      post = described_class.new(frontmatter: {})
      expect(post.tags).to eq([])
    end

    it 'returns an array when tags is already an array' do
      post = described_class.new(frontmatter: { "tags" => ["ruby", "rails"] })
      expect(post.tags).to eq(["ruby", "rails"])
    end

    it 'wraps a string tag in an array' do
      post = described_class.new(frontmatter: { "tags" => "ruby" })
      expect(post.tags).to eq(["ruby"])
    end
  end

  describe '#content' do
    it 'executes xruby code blocks and annotates `# =>` comments with their values' do
      body = <<~MARKDOWN
        ```xruby
        x = 1 + 2
        @y = x # =>
        ```

        ```xruby
        @y += 1
        @y #=>
        ```

        ```xruby
        class Greeter
          def hello = "hello"
        end
        ```

        ```xruby
        Greeter.new.hello # =>
        Greeter.new.class.name # =>
        Greeter # =>
        Greeter.name # =>
        ```
      MARKDOWN

      with_temporary_post(filename: "2026-01-01-xruby-test-post.md", body: body) do |post|
        expect(post.content).to include('class="language-ruby highlighter-rouge"')
        expect(post.content).to include("# =&gt; 3")
        expect(post.content).to include("#=&gt; 4")
        expect(post.content).to include('# =&gt; "hello"')
        expect(post.content).to include("# =&gt; Greeter")
        expect(post.content).to include('# =&gt; "Greeter"')
      end
    end
  end

  describe '#content with base_url:' do
    it 'rewrites root-relative media URLs to be absolute against the given base URL' do
      body = "![alt text](/uploads/2024/example.png)"

      with_temporary_post(filename: "2026-01-01-rewrite-media-test-post.md", body: body) do |post|
        expect(post.content).to include('src="/uploads/2024/example.png"')
        expect(post.content(base_url: "https://island94.org")).to include('src="https://island94.org/uploads/2024/example.png"')
      end
    end
  end

  describe '#published?' do
    it 'is true when the frontmatter has no published key' do
      post = described_class.new(frontmatter: {})
      expect(post.published?).to be(true)
    end

    it 'is true when published is explicitly true' do
      post = described_class.new(frontmatter: { "published" => true })
      expect(post.published?).to be(true)
    end

    it 'is false when published is explicitly false' do
      post = described_class.new(frontmatter: { "published" => false })
      expect(post.published?).to be(false)
    end
  end

  describe '.published' do
    it 'excludes unpublished posts' do
      published_post = described_class.new(filepath: "#{Rails.root}/_posts/2024-01-01-published.md", frontmatter: { "published" => true })
      unpublished_post = described_class.new(filepath: "#{Rails.root}/_posts/2024-01-01-unpublished.md", frontmatter: { "published" => false })
      allow(described_class).to receive(:all).and_return([published_post, unpublished_post])

      expect(described_class.published).to eq([published_post])
    end
  end

  describe '.create!' do
    let(:date) { Time.zone.parse("2026-01-01 12:00") }

    it 'writes a new post file to disk' do
      path = Rails.root.join("_posts", "2026-01-01-a-brand-new-test-post.md")

      begin
        post = described_class.create!(title: "A Brand New Test Post", body: "Hello world.", date: date)

        expect(File.exist?(path)).to be(true)
        expect(post.filepath).to eq(path.to_s)
        expect(post.title).to eq("A Brand New Test Post")
        expect(post.body).to include("Hello world.")
        expect(post.published?).to be(true)
      ensure
        FileUtils.rm_f(path)
        described_class.reset
      end
    end

    it 'raises and leaves the existing file untouched when a post already exists at that path' do
      path = Rails.root.join("_posts", "2026-01-01-a-conflicting-test-post.md")

      begin
        described_class.create!(title: "A Conflicting Test Post", body: "Original content.", date: date)

        expect do
          described_class.create!(title: "A Conflicting Test Post", body: "New content.", date: date)
        end.to raise_error(/File already exists/)

        expect(File.read(path)).to include("Original content.")
        expect(File.read(path)).not_to include("New content.")
      ensure
        FileUtils.rm_f(path)
        described_class.reset
      end
    end
  end
end
