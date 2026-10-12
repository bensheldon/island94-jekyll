# frozen_string_literal: true
# Custom mdl rules for weird whitespace characters that sneak in when pasting
# from apps like Apple Notes or Pages.
# Run via: bin/lint (loaded via --rulesets, enabled in .mdl_style.rb)

rule "CUSTOM001", "No object replacement characters" do
  tags :whitespace
  check do |doc|
    doc.matching_lines(/\u{FFFC}/)
  end
  fix do |doc, lines|
    lines.each do |linenum|
      doc.lines[linenum - 1] = doc.lines[linenum - 1].delete("\u{FFFC}")
    end
  end
end

rule "CUSTOM002", "No no-break spaces" do
  tags :whitespace
  check do |doc|
    doc.matching_lines(/\u{00A0}/)
  end
  fix do |doc, lines|
    lines.each do |linenum|
      doc.lines[linenum - 1] = doc.lines[linenum - 1].tr("\u{00A0}", " ")
    end
  end
end

rule "CUSTOM003", "No doubled spaces mid-line" do
  tags :whitespace
  # Spaces right after a blockquote prefix (">", ">>", "> > ", etc.) are indentation for a
  # nested list, not mid-sentence spacing -- collapsing them would change the list nesting.
  blockquote_prefix = /\A(?:>[ \t]*)*/
  doubled_space = /(?<=\S) {2,}(?=\S)/

  check do |doc|
    codeblock_lines = doc.find_type_elements(:codeblock).flat_map do |e|
      linenum = doc.element_linenumber(e)
      (linenum..(linenum + e.value.lines.count)).to_a
    end

    doc.lines.each_index.select do |i|
      line = doc.lines[i]
      line.sub(blockquote_prefix, "").match?(doubled_space)
    end.map { |i| i + 1 } - codeblock_lines
  end
  fix do |doc, lines|
    lines.each do |linenum|
      line = doc.lines[linenum - 1]
      prefix = line[blockquote_prefix]
      content = line[prefix.length..]
      doc.lines[linenum - 1] = prefix + content.gsub(doubled_space, " ")
    end
  end
end
