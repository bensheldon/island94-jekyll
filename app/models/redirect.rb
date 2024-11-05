class Redirect < ApplicationModel
  STATIC = {
    "posts" => "/"
  }

  def self.all
    STATIC.merge(Post.redirects).to_h do |key, value|
      # remove leading and trailing slashes
      [key.sub(%r{\A/}, "").sub(%r{/\z}, ""), value.sub(%r{\A/}, "").sub(%r{/\z}, "")]
    end
  end
end
