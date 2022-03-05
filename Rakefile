desc 'Create a new post'
task :new_post, [:title, :body] do |_t, args|
  ENV["TZ"] = 'America/Los_Angeles'

  title = args[:title] || ENV['POST_TITLE']
  body = args[:content] || ENV['POST_BODY']

  raise "Title cannot be empty" if title.nil?

  content = <<~MARKDOWN
    ---
    title: "#{title}"
    date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
    published: true
    tags:
    ---

    #{body}

    <blockquote markdown="1">



    </blockquote>
  MARKDOWN

  slug = title.gsub(' ','-').downcase
  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{slug}.md"
  path = File.join("_posts", filename)
  File.open(path, 'w') { |file| file.puts(content) }

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
    title: "#{title}"
    author: "#{author}"
    link: "#{link}"
    rating: #{rating}
    date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
    published: true
    layout: book
    tags:
    ---

    #{review}

    <blockquote markdown="1">



    </blockquote>
  MARKDOWN

  slug = title.gsub(' ','-').downcase
  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{slug}.md"
  path = File.join("_books", filename)
  File.open(path, 'w') { |file| file.puts(content) }

  $stdout.puts "=== Generating book review ==="
  $stdout.puts path
end
