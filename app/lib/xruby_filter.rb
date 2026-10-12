# frozen_string_literal: true
require "ripper"

# Executes ```xruby fenced code blocks as Ruby, rewriting the fence to
# ```ruby (so it still gets normal Rouge syntax highlighting) and filling in
# any trailing `# =>` / `#=>` comment with the evaluated value of that line,
# REPL-annotation style (like irb/pry/seeing_is_believing).
#
# All xruby blocks within a single #call share one execution context: a
# single Binding, opened fresh per document against an anonymous Module.
# Local variables, instance variables, and constants/classes defined in one
# block are all visible to later blocks in the same document (since every
# block reuses that one Binding — the same trick a REPL uses to keep state
# between lines), but are invisible to any other document's context — and,
# crucially, can never collide with or monkeypatch a real application
# constant (e.g. `class Post`), since they live in their own private
# namespace rather than on Object.
#
# The cost of that isolation is cosmetic: a class defined inside the
# anonymous module reports its name as e.g. "#<Module:0x00...>::Greeter"
# rather than plain "Greeter". ANONYMOUS_MODULE_PREFIX strips that prefix
# back out of any inspected `# =>` value, so the annotation reads cleanly.
#
# Lines are buffered until they parse as a complete Ruby statement (the same
# "keep reading or execute now?" check irb/pry use), so multi-line
# constructs (class/def/do...end) evaluate as a single statement. Only the
# final line of a completed statement can carry a `# =>` annotation; a
# marker on an earlier line of a multi-line statement is left untouched.
class XrubyFilter
  FENCE = /^```xruby\n(.*?)^```\n/m
  ANNOTATION = /\A(.*?)(#\s*=>).*\z/
  ANONYMOUS_MODULE_PREFIX = /#<(?:Module|Class):0x\h+>::/

  def self.call(markdown)
    new.call(markdown)
  end

  def call(markdown)
    block_binding = Module.new.module_eval("binding", __FILE__, __LINE__)

    markdown.gsub(FENCE) do
      "```ruby\n#{evaluate_block(Regexp.last_match(1), block_binding)}```\n"
    end
  end

  private

  def evaluate_block(code, block_binding)
    output = +""
    buffer = +""
    buffer_start_line = nil

    code.each_line.with_index(1) do |line, line_number|
      buffer_start_line ||= line_number
      buffer << line

      next unless complete_statement?(buffer)

      value = block_binding.eval(buffer, "(xruby)", buffer_start_line)
      output << annotate(buffer, value)

      buffer = +""
      buffer_start_line = nil
    end

    # An unterminated buffer (e.g. a missing `end`) means the block never
    # parsed as complete Ruby — eval it anyway so the real SyntaxError
    # surfaces, rather than silently dropping the trailing lines.
    block_binding.eval(buffer, "(xruby)", buffer_start_line) unless buffer.empty?

    output
  end

  def complete_statement?(code)
    !Ripper.sexp(code).nil?
  end

  def annotate(buffer, value)
    lines = buffer.lines
    last_line = lines.pop
    newline = last_line.end_with?("\n") ? "\n" : ""
    match = last_line.chomp.match(ANNOTATION)
    return buffer unless match

    code = match[1]
    marker = match[2]
    formatted_value = value.inspect.gsub(ANONYMOUS_MODULE_PREFIX, "")
    "#{lines.join}#{code.rstrip} #{marker} #{formatted_value}#{newline}"
  end
end
