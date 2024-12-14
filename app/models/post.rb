class Post < ApplicationModel
  attr_reader :filename, :slug, :frontmatter, :body

  def self.all
    # Load all files from _posts directory
    @posts ||= Dir.glob("#{Rails.root}/_posts/*.*").map do |file|
      Post.from_file(file)
    end
  end

  def self.redirects
    @redirects ||= all.each_with_object({}) do |post, hash|
      post.redirects.each do |redirect|
        hash[redirect] = RouteHelper.post_path(post)
      end
    end
  end

  def self.reset
    @posts = nil
    @redirects = nil
  end

  def self.from_file(path)
    filename = File.basename(path, '.*')
    _year, _month, _day, slug = filename.split("-", 4)

    parsed = FrontMatterParser::Parser.parse_file(path)
    new(filename: filename, slug: slug, frontmatter: parsed.front_matter, body: parsed.content)
  end

  def initialize(filename:, slug:, frontmatter:, body:)
    @filename = filename
    @slug = slug
    @frontmatter = frontmatter
    @body = body
  end

  def title
    frontmatter.fetch("title", "")
  end

  def content
    Kramdown::Document.new(body, input: 'GFM').to_html.html_safe
  end

  def published_at
    if frontmatter["date"]
      Time.parse(frontmatter["date"])
    else
      Time.parse(@filename.split("-", 3).join("-"))
    end
  end

  def published?
    frontmatter["published"] != false
  end

  def tags
    frontmatter["tags"] || []
  end

  def redirects
    frontmatter.fetch("redirect_from", [])
  end
end
