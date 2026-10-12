# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Feed" do
  describe "GET /feed" do
    let(:published_post) do
      Post.new(
        filepath: "#{Rails.root}/_posts/2024-03-21-published-post.md",
        frontmatter: { "title" => "Published Post", "date" => "2024-03-21", "published" => true },
        body: "Published content"
      )
    end

    let(:unpublished_post) do
      Post.new(
        filepath: "#{Rails.root}/_posts/2024-03-20-unpublished-post.md",
        frontmatter: { "title" => "Unpublished Post", "date" => "2024-03-20", "published" => false },
        body: "Unpublished content"
      )
    end

    before do
      allow(Post).to receive(:all).and_return([published_post, unpublished_post])
    end

    it "includes published posts" do
      get feed_path(format: :xml)

      expect(response.body).to include("Published Post")
    end

    it "excludes unpublished posts" do
      get feed_path(format: :xml)

      expect(response.body).not_to include("Unpublished Post")
    end

    it "rewrites relative asset URLs to absolute URLs" do
      post_with_image = Post.new(
        filepath: "#{Rails.root}/_posts/2024-03-22-post-with-image.md",
        frontmatter: { "title" => "Post With Image", "date" => "2024-03-22", "published" => true },
        body: "![alt text](/uploads/2024/example.png)"
      )
      allow(Post).to receive(:all).and_return([post_with_image])

      get feed_path(format: :xml)

      expect(response.body).to include(%(src="#{root_url}uploads/2024/example.png"))
      expect(response.body).not_to include('src="/uploads')
    end
  end
end
