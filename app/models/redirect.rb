class Redirect < ApplicationModel
  STATIC = {
    "posts" => "/"
  }

  def self.all
    STATIC.merge(Post.redirects)
  end
end
