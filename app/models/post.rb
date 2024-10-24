class Post < ApplicationModel
  attr_reader :frontmatter, :body

  def self.all
    # Load all files from _posts directory
    Dir.glob("#{Rails.root}/_posts/*.*").map do |file|
      Post.from_file(file)
    end
  end

  def self.from_file(path)
    parsed = FrontMatterParser::Parser.parse_file(path)
    new(frontmatter: parsed.front_matter, body: parsed.content)
  end

  def initialize(frontmatter:, body:)
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
