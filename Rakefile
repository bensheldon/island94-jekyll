require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/all'

desc 'Create a new post'
task :new_post, [:title, :body] do |_t, args|
  ENV["TZ"] = 'America/Los_Angeles'

  title = args[:title] || ENV['POST_TITLE'] || raise("Title cannot be empty")
  body = args[:content] || ENV['POST_BODY']

  content = <<~MARKDOWN
    ---
    title: #{title.to_json}
    date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
    published: true
    tags: []
    ---

    #{body}

    <blockquote markdown="1">



    </blockquote>
  MARKDOWN

  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{title.parameterize}.md"
  path = File.join("_posts", filename)
  File.write(path, content)

  $stdout.puts "=== Generating post ==="
  $stdout.puts path
end

desc 'Create a new book review'
task :new_book, [:title, :author, :link, :rating, :review] do |_t, args|
  ENV["TZ"] = 'America/Los_Angeles'

  title = args[:title] || ENV['BOOK_TITLE']
  author = args[:author] || ENV['BOOK_AUTHOR']
  link = args[:link] || ENV['BOOK_LINK']
  rating = args[:rating] || ENV['BOOK_RATING']
  review = args[:review] || ENV['BOOK_REVIEW']

  raise "Title cannot be empty" if title.nil?

  content = <<~MARKDOWN
    ---
    title: #{title.to_json}
    author: "#{author}"
    link: "#{link}"
    rating: #{rating}
    date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
    published: true
    layout: book
    tags: []
    ---

    #{review}

    <blockquote markdown="1">



    </blockquote>
  MARKDOWN

  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{title.parameterize}.md"
  path = File.join("_books", filename)
  File.write(path, content)

  $stdout.puts "=== Generating book review ==="
  $stdout.puts path
end
