class Bookmark < ApplicationModel
  attr_reader :filepath, :frontmatter, :body

  def self.all
    @bookmarks ||= Dir.glob("#{Rails.root}/_bookmarks/**/*.*").map do |filepath|
      Bookmark.from_file(filepath)
    end
  end

  def self.reset
    @bookmarks = nil
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

  def filename
    File.basename(filepath, '.*')
  end

  def project_filepath
    filepath.sub("#{Rails.root}/", "")
  end

  def title
    frontmatter.fetch("title", link)
  end

  def link
    frontmatter.fetch("link", "")
  end

  def date
    if frontmatter["date"]
      Time.parse(frontmatter["date"])
    else
      File.mtime(filepath)
    end
  end

  def content
    Kramdown::Document.new(body, input: 'GFM').to_html.html_safe
  end
end
