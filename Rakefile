desc 'Create a new post'
task :post, [:title] do |t, args|
  title = args[:title]
  post =  <<~HTML
            ---
            title: #{title}
            date: #{Time.new.strftime('%Y-%m-%d %H:%M %Z')}
            tags:
            ---

          HTML

  slug = title.gsub(' ','-').downcase
  filename = "#{Time.new.strftime('%Y-%m-%d')}-#{slug}.md"
  path = File.join("_posts", filename)
  File.open(path, 'w') { |file| file.puts(post) }

  puts path
end
