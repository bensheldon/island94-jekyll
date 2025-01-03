class Redirect < ApplicationModel
  STATIC = {
    "posts" => "/"
  }

  def self.all
    @all ||= STATIC.merge(Post.redirects).to_h do |key, value|
      # remove leading and trailing slashes
      [key.sub(%r{\A/}, "").sub(%r{/\z}, ""), value]
    end
  end

  def self.reset
    @all = nil
  end
end
