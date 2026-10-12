# frozen_string_literal: true
module Editor
  # Converts a post's Markdown into HTML for the Lexxy editor, and the editor's
  # HTML back down to Markdown when saving. The HTML → Markdown direction only
  # needs to handle the small set of elements that Lexxy produces.
  module Markdown
    BLOCK_SEPARATOR = "\n\n"

    # Keep the author's literal quotes, dashes, and ellipses rather than letting
    # kramdown convert them to typographic characters that would then be saved.
    KRAMDOWN_OPTIONS = {
      input: "GFM",
      syntax_highlighter: nil,
      auto_ids: false,
      smart_quotes: %w[apos apos quot quot],
      typographic_symbols: { hellip: "...", mdash: "---", ndash: "--", laquo: "<<", raquo: ">>", laquo_space: "<< ", raquo_space: " >>" },
    }.freeze

    # Elements Lexxy can't edit natively. They're passed through Lexxy as opaque
    # "custom attachments" that display the HTML and are saved back unchanged.
    PASSTHROUGH_TAGS = %w[
      img video audio iframe object embed script style table figure details picture
      dl div span sup sub kbd abbr small center form canvas svg
    ].freeze
    ATTACHMENT_TAG = "action-text-attachment"
    FORMATTING_TAGS = %w[strong b em i s del strike].freeze

    def self.to_html(markdown)
      html = Kramdown::Document.new(markdown.to_s, **KRAMDOWN_OPTIONS).to_html
      fragment = Nokogiri::HTML::DocumentFragment.parse(html)
      # kramdown wraps fenced code in <div class="language-x highlighter-rouge"><pre><code>;
      # Lexxy expects <pre data-language="x">.
      fragment.css("pre > code").each do |code|
        pre = code.parent
        language = code["class"].to_s[/language-(\S+)/, 1] || pre.parent["class"].to_s[/language-(\S+)/, 1]
        pre["data-language"] = language || "plain" # otherwise Lexxy guesses a language
        pre.content = code.text.chomp
      end
      fragment.css("div.highlighter-rouge").each { |div| div.replace(div.children) }
      wrap_passthrough_elements(fragment)
      fragment.to_html
    end

    def self.wrap_passthrough_elements(fragment)
      fragment.css(PASSTHROUGH_TAGS.join(", ")).each do |node|
        next if node.ancestors.any? { |ancestor| PASSTHROUGH_TAGS.include?(ancestor.name) }

        # An image link is kept together with its image.
        link = node.parent if node.name == "img" && node.parent&.name == "a" && node.parent.element_children.one? && node.parent.text.strip.empty?
        target = link || node
        target.replace(fragment.document.create_element(ATTACHMENT_TAG, "content-type" => "text/html", "content" => target.to_html))
      end
    end

    # When the `original` Markdown is given, any block whose content is unchanged
    # keeps its original Markdown so that saving produces a minimal diff.
    def self.to_markdown(html, original: nil)
      style = style_of(original.to_s)
      markdown = convert(html, style)
      return markdown if original.blank?

      reuse_unchanged_blocks(markdown, original, style)
    end

    def self.convert(html, style)
      fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
      normalize_formatting(fragment)
      straighten_quotes(Converter.new(**style).blocks(fragment.children).gsub(/\n{3,}/, BLOCK_SEPARATOR).strip)
    end

    # The blog always uses straight quotes and apostrophes.
    def self.straighten_quotes(text)
      text.to_s.tr("‘’“”", %(''""))
    end

    # Matches the conventions already used in the post being edited.
    def self.style_of(markdown)
      {
        bullet: markdown.scan(/^\s*\* /).size > markdown.scan(/^\s*- /).size ? "*" : "-",
        italic: markdown.scan(/(?<![*\w])\*(?=\S)[^*\n]+\*(?![*\w])/).size > markdown.scan(/(?<!\w)_(?=\S)[^_\n]+_(?!\w)/).size ? "*" : "_",
        html_blockquote: markdown[/<blockquote markdown=("1"|1|'1')>/],
      }
    end

    def self.reuse_unchanged_blocks(markdown, original, style)
      original_blocks, separators = split_blocks(original)
      index = {}
      original_blocks.each_with_index { |block, i| index[block_key(convert(to_html(block), style))] ||= i }

      result = +""
      previous = nil
      split_blocks(markdown).first.each_with_index do |block, position|
        current = index[block_key(block)]
        if position.positive?
          # Keep the original spacing between blocks that were adjacent and unchanged.
          result << (current && previous && current == previous + 1 ? separators[current] : BLOCK_SEPARATOR)
        end
        result << (current ? original_blocks[current] : block)
        previous = current
      end
      result
    end

    # Lexical splits formatting at link boundaries (<em>a </em><a><em>b</em></a>),
    # so hoist formatting out of links and merge adjacent identical formatting.
    def self.normalize_formatting(fragment)
      fragment.css("a").each do |link|
        while link.element_children.one? && FORMATTING_TAGS.include?(link.element_children.first.name) && link.children.one?
          format = link.element_children.first
          link.children = format.children
          link.replace(format)
          format.children = link
        end
      end
      # Put bold outside of italics: **_text_**
      fragment.css("em, i").each do |italic|
        bold = italic.children.first
        next unless italic.children.one? && %w[strong b].include?(bold.name)

        italic.children = bold.children
        italic.replace(bold)
        bold.children = italic
      end
      # Also rejoin formatting that Lexical split at line breaks and inline code,
      # which can't be formatted in Lexical: <em>a</em><code>b</code><em>c</em>.
      fragment.css(FORMATTING_TAGS.join(", ")).each do |node|
        loop do
          sibling = node.next_sibling
          if sibling&.element? && sibling.name == node.name
            node.add_child(sibling.children)
            sibling.remove
          elsif joinable_formatting_gap?(sibling, node.name)
            following = sibling.next_sibling
            node.add_child(sibling)
            if following
              node.add_child(following.children)
              following.remove
            end
          else
            break
          end
        end
      end
    end

    LIST_ITEM = /\A\s*([-*+]|\d+\.)\s/
    private_constant :LIST_ITEM

    # Compares blocks while ignoring differences Lexxy can't represent: loose
    # (blank-line separated) lists, list numbering, and repeated blank quote lines.
    def self.block_key(markdown)
      markdown.gsub(/\n\n+(?=\s*([-*+]|\d+\.)\s)/, "\n")
              .gsub(/^(\s*)\d+\.\s/, "\\11. ")
              .gsub(/^>\s*\n(>\s*\n)+/, ">\n")
    end
    private_class_method :block_key

    def self.joinable_formatting_gap?(sibling, format)
      following = sibling&.next_sibling
      case sibling&.name
      when "br" then following&.element? && following.name == format
      when "code" then following.nil? || (following.element? && following.name == format)
      else false
      end
    end
    private_class_method :joinable_formatting_gap?

    # Splits Markdown into blocks on blank lines, keeping fenced code blocks whole.
    # Returns the blocks and, for each block, the whitespace that preceded it.
    def self.split_blocks(markdown)
      blocks = []
      separators = []
      pending = +""
      fenced = false
      markdown.strip.each_line do |line|
        fenced = !fenced if line.start_with?("```", "~~~")
        if !fenced && line.strip.empty?
          pending << line
        elsif blocks.empty? || (!pending.empty? && !(blocks.last.match?(LIST_ITEM) && line.match?(LIST_ITEM)))
          separators << "\n#{pending}"
          blocks << line.dup
          pending = +""
        else
          blocks.last << pending << line # a loose list stays one block
          pending = +""
        end
      end
      [blocks.map(&:rstrip), separators]
    end

    # The visible text of the HTML, as the editor displays it, for the AI review to quote from.
    def self.to_text(html)
      fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
      fragment.css("br").each { |br| br.replace("\n") }
      fragment.css("p, li, h1, h2, h3, h4, h5, h6, pre, blockquote").each { |block| block.after(BLOCK_SEPARATOR) }
      fragment.text.gsub(/\n{3,}/, BLOCK_SEPARATOR).strip
    end

    class Converter
      HEADINGS = %w[h1 h2 h3 h4 h5 h6].freeze

      def initialize(bullet: "-", italic: "_", html_blockquote: nil)
        @bullet = bullet
        @italic = italic
        @html_blockquote = html_blockquote
      end

      def blocks(nodes, list_depth: 0)
        nodes.map { |node| block(node, list_depth: list_depth) }.join
      end

      private

      def block(node, list_depth:)
        case node.name
        when "p" then "#{escape_block_start(inline(node.children).strip)}#{BLOCK_SEPARATOR}"
        when *HEADINGS then "#{'#' * node.name[1].to_i} #{inline(node.children).strip}#{BLOCK_SEPARATOR}"
        when "blockquote" then "#{quote(node)}#{BLOCK_SEPARATOR}"
        when "pre" then "#{code_block(node)}#{BLOCK_SEPARATOR}"
        when "ul", "ol" then "#{list(node, depth: list_depth)}#{BLOCK_SEPARATOR if list_depth.zero?}"
        when "hr" then "---#{BLOCK_SEPARATOR}"
        when "div", "section", "article" then blocks(node.children, list_depth: list_depth)
        when ATTACHMENT_TAG then "#{attachment(node)}#{BLOCK_SEPARATOR}"
        when "text" then node.text.strip.empty? ? "" : "#{inline([node]).strip}#{BLOCK_SEPARATOR}"
        when "comment" then ""
        else
          # Inline content (or anything unrecognized) at the block level becomes its own paragraph.
          content = inline([node]).strip
          content.empty? ? "" : "#{content}#{BLOCK_SEPARATOR}"
        end
      end

      def quote(node)
        content = node.element_children.any? { |child| block_element?(child) } ? blocks(node.children) : inline(node.children)
        return "#{@html_blockquote}\n\n#{content.strip}\n\n</blockquote>" if @html_blockquote

        content.strip.lines.map { |line| line.strip.empty? ? ">" : "> #{line.chomp}" }.join("\n")
      end

      def code_block(node)
        language = node["data-language"].presence || node.at_css("code")&.[]("class").to_s[/language-(\S+)/, 1]
        language = nil if language == "plain"
        "```#{language}\n#{code_text(node).chomp}\n```"
      end

      def code_text(node)
        node.children.map do |child|
          if child.name == "br" then "\n"
          elsif child.element? then code_text(child)
          else child.text
          end
        end.join
      end

      def list(node, depth:)
        indent = "  " * depth
        node.element_children.select { |child| child.name == "li" }.each_with_index.map do |item, index|
          marker = node.name == "ol" ? "#{index + 1}." : @bullet
          nested = item.element_children.select { |child| %w[ul ol].include?(child.name) }
          text = inline(item.children.reject { |child| nested.include?(child) }).strip
          lines = ["#{indent}#{marker} #{text}"]
          nested.each { |sublist| lines << list(sublist, depth: depth + 1) }
          lines.join("\n")
        end.join(loose?(node) ? BLOCK_SEPARATOR : "\n")
      end

      # A list whose items contain paragraphs is separated by blank lines.
      def loose?(list)
        list.element_children.any? { |item| item.element_children.any? { |child| child.name == "p" } }
      end

      # Escapes literal text that Markdown would otherwise treat as formatting.
      def escape(text)
        text.gsub(/[\\*`]/) { |char| "\\#{char}" }
            .gsub(/(?<!\w)_|_(?!\w)/, "\\_") # emphasis, but not snake_case
            .gsub(/\[(?=[^\]]*\][(\[])/, "\\[") # [text](url) and [text][ref]
            .gsub(%r{<(?=[A-Za-z/!])}, "\\<") # raw HTML
            .gsub(/&(?=#?\w+;)/, "&amp;") # HTML entities, e.g. a literal "&copy;"
            .gsub("~~", "\\~\\~") # strikethrough
      end

      # Escapes a paragraph that would otherwise start a heading, quote, or list.
      def escape_block_start(text)
        text.sub(/\A(#|>|[-+*](?= )|\d+(?=\. ))/) { |marker| marker.match?(/\d/) ? "#{marker}\\" : "\\#{marker}" }
      end

      # Lexxy pads attachments with spaces, so don't let spaces double up.
      def inline(nodes)
        nodes.each_with_object(+"") do |node, result|
          part = inline_node(node)
          part = part.lstrip if result.end_with?(" ") && part.start_with?(" ") && node.name != "code"
          result << part
        end
      end

      def inline_node(node)
        case node.name
        when "text"
          text = escape(node.text.gsub(/\s*\n\s*/, " ").squeeze(" "))
          node.previous_sibling&.name == "br" ? text.lstrip : text
        when "br" then "\n"
        when "strong", "b" then wrap(node, "**", %w[strong b])
        when "em", "i" then wrap(node, @italic, %w[em i])
        when "s", "del", "strike" then wrap(node, "~~", %w[s del strike])
        when "code" then code_span(node.text)
        when "a" then "[#{inline(node.children)}](#{node['href']}#{%( "#{node['title']}") if node['title'].present?})"
        when "img" then image(node)
        when ATTACHMENT_TAG then attachment(node)
        when "blockquote", "ul", "ol", "pre" then "#{BLOCK_SEPARATOR}#{block(node, list_depth: 0)}"
        else
          # Keep the content of wrappers like <p> and Lexical's styled <span>s.
          inline(node.children)
        end
      end

      # Emphasis markers must hug their content, so edge whitespace is moved outside of them.
      # Lexxy nests equivalent tags (e.g. <b><strong>), so only the outermost one adds a marker.
      def wrap(node, marker, equivalent_tags)
        content = inline(node.children)
        return content if content.strip.empty? || node.ancestors.any? { |ancestor| equivalent_tags.include?(ancestor.name) }

        leading = content[/\A\s*/]
        trailing = content[/\s*\z/]
        "#{leading}#{marker}#{content.strip}#{marker}#{trailing}"
      end

      def image(img)
        title = %( "#{img['title']}") if img["title"].present?
        "![#{img['alt']}](#{img['src']}#{title})"
      end

      # Restores the HTML that was passed through Lexxy, as a Markdown image when possible.
      def attachment(node)
        content = Nokogiri::HTML::DocumentFragment.parse(node["content"].to_s)
        root = content.element_children.first if content.element_children.one?
        if root&.name == "img"
          image(root)
        elsif root&.name == "a" && root.element_children.one? && root.element_children.first.name == "img"
          "[#{image(root.element_children.first)}](#{root['href']})"
        else
          node["content"].to_s
        end
      end

      def code_span(text)
        fence = "`" * ((text.scan(/`+/).map(&:length).max || 0) + 1)
        padding = text.start_with?("`") || text.end_with?("`") ? " " : ""
        "#{fence}#{padding}#{text}#{padding}#{fence}"
      end

      def block_element?(node)
        %w[p pre ul ol blockquote hr div].include?(node.name) || HEADINGS.include?(node.name)
      end
    end
  end
end
