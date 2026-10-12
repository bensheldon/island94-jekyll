# frozen_string_literal: true
module Editor
  # A blog post file in _posts/, edited directly on the filesystem. The front
  # matter is kept as raw YAML so that saving never reformats fields the editor
  # doesn't touch.
  class Document
    include ActiveModel::Model
    include ActiveModel::Attributes

    class NotFound < StandardError; end

    FRONT_MATTER = /\A---[ \t]*\r?\n(.*?)^---[ \t]*\r?\n/m

    attribute :filepath, :string
    attribute :front_matter, :string, default: ""
    attribute :body, :string, default: ""

    validate :front_matter_is_yaml

    def self.root
      Rails.root.join("_posts")
    end

    def self.all
      Dir.glob(root.join("**/*.{md,markdown}")).map { |path| from_file(path) }.sort_by(&:date).reverse
    end

    def self.find(id)
      path = Dir.glob(root.join("**/*.{md,markdown}")).find { |file| File.basename(file, ".*") == id.to_s }
      raise NotFound, "Couldn't find a post named #{id}" unless path

      from_file(path)
    end

    def self.from_file(path)
      new(filepath: path.to_s).tap(&:reload)
    end

    # Creates an unpublished post file using the same conventions as `rake new_post`.
    def self.create!(title:)
      post = Post.create!(title: title, published: false)
      from_file(post.filepath)
    end

    def id
      File.basename(filepath, ".*")
    end

    def to_param
      id
    end

    def persisted?
      true
    end

    def reload
      self.content = File.read(filepath)
      self
    end

    # The complete file contents.
    # The blank lines around the body are preserved from the original file so
    # that saving an unchanged document doesn't alter it.
    def content
      front = front_matter.strip.empty? ? "" : "#{front_matter.chomp}\n"
      "---\n#{front}---\n#{@body_prefix || "\n"}#{body.rstrip}#{@body_suffix || "\n"}"
    end

    def content=(raw)
      raw = normalize_newlines(raw)
      if (match = raw.match(FRONT_MATTER))
        self.front_matter = match[1]
        raw = match.post_match
      else
        self.front_matter = ""
      end
      @body_prefix = raw[/\A\s*\n/] || ""
      @body_suffix = raw.strip.empty? ? "" : raw[/\s*\z/]
      self.body = raw.delete_prefix(@body_prefix)
    end

    def front_matter=(value)
      super(normalize_newlines(value))
    end

    def body=(value)
      super(normalize_newlines(value))
    end

    def metadata
      YAML.safe_load(front_matter, permitted_classes: [Date, Time]) || {}
    rescue Psych::Exception
      {}
    end

    def title
      metadata["title"].to_s
    end

    # Changes the title within the raw front matter, leaving everything else as written.
    def title=(value)
      value = value.to_s.strip
      return if value.empty? || value == title

      line = "title: #{value.to_json}"
      self.front_matter = if front_matter.match?(/^title:.*$/)
                            front_matter.sub(/^title:.*$/, line)
                          else
                            "#{line}\n#{front_matter}"
                          end
    end

    # The body as HTML for the Lexxy editor. Assigning HTML converts it back to Markdown.
    def body_html
      Markdown.to_html(body)
    end

    def body_html=(html)
      self.body = Markdown.to_markdown(html, original: body)
    end

    # The visible text of the body, as displayed in the editor.
    def text
      Markdown.to_text(body_html)
    end

    def date
      Time.zone.parse(metadata["date"].to_s) || Time.zone.parse(id.split("-", 4).first(3).join("-"))
    rescue ArgumentError
      Time.zone.at(0)
    end

    def published?
      metadata["published"] != false
    end

    def project_filepath
      filepath.delete_prefix("#{Rails.root}/")
    end

    # The path of the post on the blog (in development).
    def public_path
      "/#{date.strftime('%Y/%m')}/#{id.split('-', 4).last.downcase}"
    end

    def save # rubocop:disable Naming/PredicateMethod
      return false unless valid?

      File.write(filepath, content)
      Post.reset
      true
    end

    def save!
      save || raise(ActiveModel::ValidationError, self)
    end

    # Applies attributes from the editor form and writes the file.
    # Pass straighten_quotes: true to straighten the quotes throughout the whole
    # post, not just in the paragraphs that changed.
    def update(attrs = {}, straighten_quotes: false, **more)
      attrs = attrs.to_h.symbolize_keys.merge(more)
      self.front_matter = attrs[:front_matter] if attrs.key?(:front_matter)
      self.title = attrs[:title] if attrs.key?(:title)
      self.body = attrs[:body] if attrs.key?(:body)
      self.body_html = attrs[:body_html] if attrs.key?(:body_html)
      if straighten_quotes
        self.title = Markdown.straighten_quotes(title)
        self.body = Markdown.straighten_quotes(body)
      end
      save
    end

    def revisions
      Revision.for_document(self)
    end

    def snapshot!(label: nil, major: false)
      Revision.create!(document_id: id, content: content, label: label, major: major)
    end

    private

    def normalize_newlines(value)
      value.to_s.gsub("\r\n", "\n")
    end

    def front_matter_is_yaml
      YAML.safe_load(front_matter, permitted_classes: [Date, Time])
    rescue Psych::Exception => e
      errors.add(:front_matter, "is not valid YAML: #{e.message}")
    end
  end
end
