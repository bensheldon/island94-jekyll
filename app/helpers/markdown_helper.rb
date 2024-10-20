module MarkdownHelper
  def markdownify(text)
    Kramdown::Document.new(text, input: 'GFM').to_html.html_safe
  end
end
