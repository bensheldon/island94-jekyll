# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Posts" do
  it "renders executed xruby code blocks with their `# =>` values" do
    body = <<~MARKDOWN
      ```xruby
      x = 1 + 2
      @y = x # =>
      ```

      ```xruby
      @y += 1
      @y #=>
      ```

      ```xruby
      class Greeter
        def hello = "hello"
      end
      ```

      ```xruby
      Greeter.new.hello # =>
      Greeter.new.class.name # =>
      Greeter # =>
      Greeter.name # =>
      ```
    MARKDOWN

    with_temporary_post(filename: "2026-01-01-xruby-system-test-post.md", body: body) do |post|
      visit "/#{post.published_at.strftime('%Y/%m')}/#{post.slug}"

      expect(page).to have_title(post.title)
      within ".post-content" do
        expect(page).to have_css(".language-ruby")
        expect(page).to have_text("# => 3")
        expect(page).to have_text("#=> 4")
        expect(page).to have_text('# => "hello"')
        expect(page).to have_text("# => Greeter")
        expect(page).to have_text('# => "Greeter"')
      end
    end
  end
end
