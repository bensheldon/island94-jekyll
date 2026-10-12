# frozen_string_literal: true
require 'front_matter_parser'

class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.cache
    @_cache ||= {}
  end

  def self.reset
    @_cache = {}
  end

  # Writes a front-matter markdown file, raising if one already exists at that path.
  def self.write_frontmatter_file(path, frontmatter:, body:)
    raise "File already exists: #{path.sub("#{Rails.root}/", '')}" if File.exist?(path)

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, "#{frontmatter.to_yaml.strip}\n---\n\n#{body}\n")
  end
end
