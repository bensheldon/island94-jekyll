desc 'Create a new post'
task :post, [:title] do |t, args|
  title = args[:title]
  content =  <<~MARKDOWN
    ---
    title: #{title}
    date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
    published: true
    tags:
    ---
  MARKDOWN

  slug = title.gsub(' ','-').downcase
  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{slug}.md"
  path = File.join("_posts", filename)
  File.open(path, 'w') { |file| file.puts(content) }

  $stdout.puts "=== Generating post ==="
  $stdout.puts path
end
