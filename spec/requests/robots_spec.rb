require "rails_helper"

RSpec.describe "Robots", type: :request do
  describe "GET /robots.txt" do
    it "returns a successful response with correct content type" do
      get robots_path(format: :txt)
      
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to include("Sitemap: #{sitemap_url(format: :xml)}")
    end
  end

  describe "GET /sitemap.xml" do
    let(:post) do
      Post.new(
        filepath: "#{Rails.root}/_posts/2024-03-21-test-post.md",
        frontmatter: { "title" => "Test Post" },
        body: "Test content"
      )
    end

    before do
      allow(Post).to receive(:all).and_return([post])
    end

    it "returns a successful response with correct content type" do
      get sitemap_path(format: :xml)
      
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/xml")
    end

    it "includes the root url" do
      get sitemap_path(format: :xml)
      
      expect(response.body).to include("<loc>#{root_url}</loc>")
    end

    it "includes posts" do
      get sitemap_path(format: :xml)
      
      expect(response.body).to include("<loc>#{post_url(post)}</loc>")
    end

    it "has valid XML structure" do
      get sitemap_path(format: :xml)
      
      expect(response.body).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(response.body).to include('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
      expect(response.body).to include('</urlset>')
    end
  end
end 