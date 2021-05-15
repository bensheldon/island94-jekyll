desc 'Create a new post'
task :new_post, [:title, :body] do |_t, args|
  ENV["TZ"] = 'America/Los_Angeles'

  title = args[:title] || ENV['POST_TITLE']
  body = args[:content] || ENV['POST_BODY']

  raise "Title cannot be empty" if title.nil?

  content = <<~MARKDOWN
    ---
    title: #{title}
    date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
    published: true
    tags:
    ---

    #{body}
  MARKDOWN

  slug = title.gsub(' ','-').downcase
  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{slug}.md"
  path = File.join("_posts", filename)
  File.open(path, 'w') { |file| file.puts(content) }

  $stdout.puts "=== Generating post ==="
  $stdout.puts path
end
