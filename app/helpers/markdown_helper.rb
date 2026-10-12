# frozen_string_literal: true
module MarkdownHelper
  def markdownify(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter_opts: { formatter: RougeHtmlFormatter }).to_html.html_safe # rubocop:disable Rails/OutputSafety
  end
end
