# frozen_string_literal: true
require_relative "../rails_helper"

RSpec.describe XrubyFilter do
  describe ".call" do
    it "rewrites an xruby fence to a ruby fence" do
      markdown = <<~MARKDOWN
        ```xruby
        1 + 1
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to eq(<<~MARKDOWN)
        ```ruby
        1 + 1
        ```
      MARKDOWN
    end

    it "fills in a trailing `# =>` comment with the evaluated value" do
      markdown = <<~MARKDOWN
        ```xruby
        1 + 1 # =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include("1 + 1 # => 2")
    end

    it "fills in a trailing `#=>` comment with the evaluated value" do
      markdown = <<~MARKDOWN
        ```xruby
        1 + 1 #=>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include("1 + 1 #=> 2")
    end

    it "renders the value with #inspect, quoting strings" do
      markdown = <<~MARKDOWN
        ```xruby
        "hello" # =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include('"hello" # => "hello"')
    end

    it "replaces a stale value already present after the marker" do
      markdown = <<~MARKDOWN
        ```xruby
        1 + 1 # => 999
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include("1 + 1 # => 2")
      expect(described_class.call(markdown)).not_to include("999")
    end

    it "leaves lines without a marker untouched, though still executed" do
      markdown = "```xruby\nx = 1 + 2\nx # =>\n```\n"

      result = described_class.call(markdown)
      expect(result).to include("x = 1 + 2\n")
      expect(result).to include("x # => 3")
    end

    it "persists instance variables across separate xruby blocks in one document" do
      markdown = <<~MARKDOWN
        ```xruby
        @count = 1
        ```

        ```xruby
        @count += 1
        @count # =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include("@count # => 2")
    end

    it "persists local variables across separate xruby blocks in one document" do
      markdown = <<~MARKDOWN
        ```xruby
        x = 1
        ```

        ```xruby
        x += 1
        x # =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include("x # => 2")
    end

    it "does not persist local variables between separate .call invocations" do
      markdown = <<~MARKDOWN
        ```xruby
        x = 1
        ```
      MARKDOWN
      described_class.call(markdown)

      other_markdown = <<~MARKDOWN
        ```xruby
        x # =>
        ```
      MARKDOWN

      expect { described_class.call(other_markdown) }.to raise_error(NameError)
    end

    it "evaluates a multi-line statement as one chunk, and later blocks can use it" do
      markdown = <<~MARKDOWN
        ```xruby
        class Greeter
          def hello = "hello"
        end
        ```

        ```xruby
        Greeter.new.hello # =>
        ```
      MARKDOWN

      result = described_class.call(markdown)
      expect(result).to include(<<~RUBY)
        class Greeter
          def hello = "hello"
        end
      RUBY
      expect(result).to include('Greeter.new.hello # => "hello"')
    end

    it "isolates constants between separate .call invocations" do
      markdown = <<~MARKDOWN
        ```xruby
        class Thing
          VALUE = 1
        end
        Thing::VALUE # =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include("Thing::VALUE # => 1")
      expect(described_class.call(markdown)).to include("Thing::VALUE # => 1")
    end

    it "gives classes defined in a block a clean, unprefixed name" do
      markdown = <<~MARKDOWN
        ```xruby
        class Greeter
        end
        Greeter.name # =>
        Greeter # =>
        ```
      MARKDOWN

      result = described_class.call(markdown)
      expect(result).to include('Greeter.name # => "Greeter"')
      expect(result).to include("Greeter # => Greeter")
    end

    it "does not affect a real top-level class of the same name" do
      markdown = <<~MARKDOWN
        ```xruby
        class String
          def shout = upcase + "!"
        end
        ```
      MARKDOWN

      described_class.call(markdown)

      expect(String.method_defined?(:shout)).to be(false)
    end

    it "does not affect a real application model of the same name" do
      markdown = <<~MARKDOWN
        ```xruby
        class Post
          def evil = "gotcha"
        end
        ```
      MARKDOWN

      described_class.call(markdown)

      expect(Post.method_defined?(:evil)).to be(false)
    end

    it "allows reopening a class defined earlier in the same document" do
      markdown = <<~MARKDOWN
        ```xruby
        class Greeter
          def hello = "hello"
        end
        ```

        ```xruby
        class Greeter
          def bye = "bye"
        end
        Greeter.new.bye # =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to include('Greeter.new.bye # => "bye"')
    end

    it "does not leak classes into the global namespace after processing" do
      markdown = <<~MARKDOWN
        ```xruby
        class Greeter
        end
        ```
      MARKDOWN

      described_class.call(markdown)

      expect(Object.const_defined?(:Greeter)).to be(false)
    end

    it "raises a SyntaxError for genuinely broken Ruby" do
      markdown = <<~MARKDOWN
        ```xruby
        class Broken
        ```
      MARKDOWN

      expect { described_class.call(markdown) }.to raise_error(SyntaxError)
    end

    it "leaves non-xruby fences untouched" do
      markdown = <<~MARKDOWN
        ```ruby
        1 + 1 # =>
        ```

        ```javascript
        1 + 1 // =>
        ```
      MARKDOWN

      expect(described_class.call(markdown)).to eq(markdown)
    end
  end
end
