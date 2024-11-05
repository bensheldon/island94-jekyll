class Post < ApplicationModel
  attr_reader :slug, :frontmatter, :body

  def self.all
    # Load all files from _posts directory
    Dir.glob("#{Rails.root}/_posts/*.*").map do |file|
      Post.from_file(file)
    end
  end

  def self.redirects
    all.each_with_object({}) do |post, hash|
      post.redirects.each do |redirect|
        hash[redirect] = RouteHelper.post_path(post)
      end
    end
  end

  def self.from_file(path)
    filename = File.basename(path, '.*')
    _year, _month, _day, slug = filename.split("-", 4)

    parsed = FrontMatterParser::Parser.parse_file(path)
    new(slug: slug, frontmatter: parsed.front_matter, body: parsed.content)
  end

  def initialize(slug:, frontmatter:, body:)
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
      nil
    end
  end

  def published?
    frontmatter["published"] != false
  end

  def tags
    frontmatter.fetch("tags", [])
  end

  def redirects
    frontmatter.fetch("redirect_from", [])
  end
end
