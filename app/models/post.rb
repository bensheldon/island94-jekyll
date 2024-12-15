class Post < ApplicationModel
  attr_reader :filepath, :frontmatter, :body

  def self.all
    # Load all files from _posts directory
    @posts ||= Dir.glob("#{Rails.root}/_posts/*.*").map do |filepath|
      Post.from_file(filepath)
    end
  end

  def self.redirects
    @redirects ||= all.each_with_object({}) do |post, hash|
      post.redirects.each do |redirect|
        hash[redirect] = post
      end
    end
  end

  def self.reset
    @posts = nil
    @redirects = nil
  end

  def self.from_file(path)
    parsed = FrontMatterParser::Parser.parse_file(path)
    new(filepath: path, frontmatter: parsed.front_matter, body: parsed.content)
  end

  def initialize(filepath:, frontmatter:, body:)
    @filepath = filepath
    @frontmatter = frontmatter
    @body = body
  end

  def slug
    @slug ||= begin
      _year, _month, _day, slug = filename.split("-", 4)
      slug
    end
  end

  def project_filepath
    filepath.sub("#{Rails.root}/", "")
  end

  def filename
    File.basename(filepath, '.*')
  end

  def title
    frontmatter.fetch("title", "")
  end

  def content
    @content ||= Kramdown::Document.new(body, input: 'GFM').to_html.html_safe
  end

  def published_at
    @published_at ||= begin
      if frontmatter["date"]
        Time.parse(frontmatter["date"])
      else
        Time.parse(filename.split("-", 3).join("-"))
      end
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

  def related_posts
    return [] if tags.empty?

    self.class.all
      .select(&:published?)
      .select { |post| (post.tags & tags).any? }
      .reject { |post| post == self }
      .sort_by(&:published_at)
      .reverse
      .first(5) # Limit to 5 related posts
  end
end
