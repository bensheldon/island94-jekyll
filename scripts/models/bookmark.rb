require 'yaml'
require 'securerandom'
require 'time'

#
# require './scripts/models/bookmark.rb'
# Bookmark.load_all
#

class Bookmark
  attr_accessor :link, :title, :tags, :notes, :date, :published, :id

  def self.load_all
    Dir.glob("_bookmarks/*.md").map do |path|
      load(path)
    end.sort_by(&:date)
  end

  def self.load(path)
    id = File.basename(path, ".md").split("_")[1]

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
      id: id
    )
  end

  def initialize(link:, title: nil, tags: nil, notes: nil, date: nil, published: true, id: nil)
    @link = link
    @title = title
    @tags = tags
    @notes = notes
    @date = date || Time.new
    @published = published
    @id = id || SecureRandom.uuid
  end

  def save
    File.write(filepath, to_s)
  end

  def filepath
    "_bookmarks/#{filename}"
  end

  def filename
    "#{date.strftime('%Y-%m-%d')}_#{id}.md"
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
end
