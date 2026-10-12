# frozen_string_literal: true
require "rails_helper"

RSpec.describe Editor::Markdown do
  it "round-trips common Markdown through the editor's HTML" do
    markdown = <<~MARKDOWN.strip
      ## A heading

      Some **bold**, _italic_, `code`, and a [link](https://example.com).
      A line break.

      - one
      - two
        - nested

      1. first
      2. second

      > A quote

      ```ruby
      def hello
        "world"
      end
      ```
    MARKDOWN

    html = described_class.to_html(markdown)
    expect(html).to include('<pre data-language="ruby">')
    expect(described_class.to_markdown(html)).to eq markdown
  end

  it "preserves literal quotes, dashes, and ellipses" do
    markdown = %(It's "quoted" -- and --- so on...)
    expect(described_class.to_markdown(described_class.to_html(markdown))).to eq markdown
  end

  it "converts Lexxy's HTML to Markdown" do
    html = <<~HTML
      <p><b><strong>Bold</strong></b>, <i><em>italic</em></i> and <s>struck</s>.<br>Next line</p>
      <pre data-language="js" data-highlight-language="js">const a = 1;<br>const b = 2;</pre>
      <ul><li>item</li></ul>
    HTML

    expect(described_class.to_markdown(html)).to eq <<~MARKDOWN.strip
      **Bold**, _italic_ and ~~struck~~.
      Next line

      ```js
      const a = 1;
      const b = 2;
      ```

      - item
    MARKDOWN
  end

  it "keeps the original Markdown of unchanged blocks" do
    original = "Some *emphasis*.\n\nChange me.\n\n```\na\n\nb\n```"
    html = described_class.to_html(original).sub("Change me.", "Changed <em>this</em>.")

    expect(described_class.to_markdown(html, original: original)).to eq "Some *emphasis*.\n\nChanged *this*.\n\n```\na\n\nb\n```"
  end

  it "straightens quotes in changed blocks, leaving unchanged ones alone" do
    original = "It’s unchanged.\n\nIt’s “changing.”"
    html = described_class.to_html(original).sub("changing", "changed")

    expect(described_class.to_markdown(html, original: original)).to eq %(It’s unchanged.\n\nIt's "changed.")
  end

  it "keeps literal punctuation literal when a paragraph is edited" do
    original = 'A literal \\*star\\*, a \\[fake\\](link), `code`, and snake_case.'
    html = described_class.to_html(original).sub("literal", "changed")

    expect(described_class.to_markdown(html, original: original)).to eq 'A changed \\*star\\*, a \\[fake](link), `code`, and snake_case.'
    expect(described_class.to_html(described_class.to_markdown(html))).to include("*star*", "[fake](link)")
  end

  it "keeps literal entities and tildes literal when a paragraph is edited" do
    original = "A literal &amp;copy; and \\~\\~not struck\\~\\~ and ~5 minutes."
    html = described_class.to_html(original).sub("literal", "changed")

    markdown = described_class.to_markdown(html)
    expect(described_class.to_html(markdown)).to include("&amp;copy;", "~~not struck~~", "~5 minutes")
    expect(markdown).to include("~5 minutes")
  end

  it "escapes text that would start a heading or list" do
    expect(described_class.to_markdown("<p># not a heading</p><p>1. not a list</p>")).to eq "\\# not a heading\n\n1\\. not a list"
  end

  it "extracts the displayed text" do
    expect(described_class.to_text("<p>One <b>two</b></p><p>Three</p>")).to eq "One two\n\nThree"
  end
end
