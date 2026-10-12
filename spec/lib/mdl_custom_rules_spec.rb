# frozen_string_literal: true
require_relative "../rails_helper"
require "open3"
require "tempfile"

# rubocop:disable-next RSpec/DescribeClass -- exercises the .mdl_rules.rb ruleset via the mdl CLI, not a Ruby class
RSpec.describe "custom mdl rules for weird whitespace" do
  def run_mdl(text, fix: false)
    Tempfile.create(["mdl_fixture", ".md"]) do |file|
      file.write(text)
      file.flush

      command = [
        "bundle", "exec", "mdl",
        "--style", Rails.root.join(".mdl_style.rb").to_s,
        "--rulesets", Rails.root.join(".mdl_rules.rb").to_s,
        "--ignore-front-matter"
      ]
      command << "--fix" if fix
      command << file.path

      stdout, = Open3.capture3(*command, chdir: Rails.root.to_s)
      [stdout, File.read(file.path)]
    end
  end

  it "flags object replacement characters" do
    stdout, = run_mdl("the [\u{FFFC}`thing`\u{FFFC}](https://example.com) library\n")
    expect(stdout).to include("CUSTOM001")
  end

  it "flags no-break spaces" do
    stdout, = run_mdl("before\u{00A0}`code`\u{00A0}after\n")
    expect(stdout).to include("CUSTOM002")
  end

  it "flags doubled spaces mid-line, but not code-block indentation" do
    text = "the Fiber  `resume` behavior\n\n```ruby\n  def start\n    @resource = 1\n  end\n```\n"
    stdout, = run_mdl(text)
    expect(stdout).to include("CUSTOM003")
    expect(stdout.scan(/^.*CUSTOM003.*$/).join).to include(":1:")
  end

  it "does not flag or collapse nested-list indentation after a blockquote marker" do
    text = "> * Examples of pain:\n>   * Devise.\n>     * a nested detail\n"
    stdout, fixed = run_mdl(text, fix: true)
    expect(stdout).not_to include("CUSTOM003")
    expect(fixed).to eq(text)
  end

  it "still flags and collapses a genuine doubled space inside blockquote content" do
    stdout, fixed = run_mdl("> some  doubled space\n", fix: true)
    expect(stdout).to include("CUSTOM003")
    expect(fixed).to eq("> some doubled space\n")
  end

  it "flags trailing whitespace" do
    stdout, = run_mdl("line one \nline two\n")
    expect(stdout).to include("MD009")
  end

  it "does not flag an intentional 2-space hard line break" do
    stdout, = run_mdl("line one  \nline two\n")
    expect(stdout).not_to include("MD009")
  end

  it "flags multiple consecutive blank lines" do
    stdout, = run_mdl("paragraph one\n\n\nparagraph two\n")
    expect(stdout).to include("MD012")
  end

  it "does not flag a single blank line between paragraphs" do
    stdout, = run_mdl("paragraph one\n\nparagraph two\n")
    expect(stdout).not_to include("MD012")
  end

  it "flags a heading not surrounded by blank lines" do
    stdout, = run_mdl("paragraph\n### Heading\nmore text\n")
    expect(stdout).to include("MD022")
  end

  it "does not flag a heading already surrounded by blank lines" do
    stdout, = run_mdl("paragraph\n\n### Heading\n\nmore text\n")
    expect(stdout).not_to include("MD022")
  end

  it "fixes all of the above in one pass" do
    lines = [
      "the [\u{FFFC}`thing`\u{FFFC}](https://example.com) library",
      "",
      "before\u{00A0}`code`\u{00A0}after",
      "",
      "the Fiber  `resume` behavior",
      "",
      "",
      "trailing space here" + " ",
    ]
    text = "#{lines.join("\n")}\n"

    _, fixed = run_mdl(text, fix: true)

    expected_lines = [
      "the [`thing`](https://example.com) library",
      "",
      "before `code` after",
      "",
      "the Fiber `resume` behavior",
      "",
      "trailing space here",
    ]
    expect(fixed).to eq("#{expected_lines.join("\n")}\n")

    recheck_stdout, = run_mdl(fixed)
    expect(recheck_stdout).to eq("")
  end
end
