require "jekyll"
require 'yaml'
require 'securerandom'
require 'time'
require 'metainspector'

#
# require './scripts/models/bookmark.rb'
# Bookmark.load_all
#

class Bookmark
  attr_accessor :link, :title, :tags, :notes, :date, :published, :slug

  def self.load_all
    Dir.glob("_bookmarks/**/*.md").map do |path|
      puts path
      load(path)
    end.sort_by(&:date)
  end

  def self.load(path)
    slug = File.basename(path, ".md")

    contents = File.read(path)
    documents = contents.split("---").map(&:strip).reject(&:empty?)
    frontmatter = YAML.safe_load(documents[0] || "")
    body = documents[1] || ""
    puts frontmatter["date"]

    puts path

    new(
      link: frontmatter["link"],
      title: frontmatter["title"],
      tags: frontmatter["tags"],
      notes: body,
      date: Time.parse(frontmatter["date"]),
      published: frontmatter["published"],
      slug: slug
    )
  end

  def initialize(link:, title: nil, tags: nil, notes: nil, date: nil, published: true, slug: nil)
    @link = link
    @title = title
    @tags = tags
    @notes = notes
    @date = date || Time.new
    @published = published
    @slug = slug || generate_slug
  end

  def save
    FileUtils.mkdir_p(File.dirname(filepath))
    File.write(filepath, to_s)
  end

  def filepath
    "_bookmarks/#{date.strftime("%Y")}/#{filename}"
  end

  def filename
    "#{slug}.md"
  end

  def fetch_title
    page = MetaInspector.new(@link)
    self.title = page.best_title
  rescue StandardError => e
    puts e
    nil
  end

  def to_s
    frontmatter = {
      link: link,
      date: date.strftime('%Y-%m-%d %H:%M %Z'),
      published: published,
      title: title,
      tags: tags,
    }.transform_keys(&:to_s)
    body = notes&.strip

    <<~MARKDOWN
      #{frontmatter.to_yaml.strip}
      ---

      #{body}
    MARKDOWN
  end

  private

  def generate_slug
    parameterized_link = (link || "").strip.gsub(/https?:\/\//, "")
    parameterized_link = Jekyll::Utils.slugify(parameterized_link, mode: "latin")
    parameterized_link = Jekyll::Utils.slugify(parameterized_link, mode: "ascii")
    parameterized_link = parameterized_link[0..150].sub(/-$/, "")
    "#{date.strftime('%Y-%m-%d')}-#{parameterized_link}"
  end
end
