# frozen_string_literal: true
# Writes a real file into _posts/ (Post.all has no injectable path, so this
# is the only way to exercise it end-to-end), yields the loaded Post, then
# always deletes the file and busts Post's memoized .all cache — so specs
# never need to commit a permanent "test" post to the real blog.
module TemporaryPost
  def with_temporary_post(filename:, body:, **frontmatter)
    frontmatter = { title: "Temporary Test Post", published: true, tags: [] }.merge(frontmatter)
    front_matter_yaml = frontmatter.map { |key, value| "#{key}: #{value.to_json}" }.join("\n")
    path = Rails.root.join("_posts", filename)

    File.write(path, "---\n#{front_matter_yaml}\n---\n\n#{body}")
    Post.reset

    post = Post.all.find { |p| p.filepath == path.to_s }
    raise "temporary post not found after writing #{path}" unless post

    yield post
  ensure
    FileUtils.rm_f(path)
    Post.reset
  end
end

RSpec.configure do |config|
  config.include TemporaryPost
end
