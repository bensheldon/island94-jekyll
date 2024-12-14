class PostsController < ApplicationController
  LIMIT = 10

  def index
    @limit = LIMIT
    @page = params.fetch(:page, 1).to_i
    @posts = Post.all.reverse.drop((@page - 1) * @limit).take(@limit)
  end

  def show
    # remove any trailing extension
    slug_param = params[:slug].sub(/\.[^.]*\z/, "").downcase
    @post = Post.all.find { |post| post.slug.downcase == slug_param }
    raise ActionController::RoutingError, "Not Found" unless @post
  end

  def tag
    tag_slug = params[:tag_slug]
    @tag = Post.all.flat_map(&:tags).find { |tag| tag.downcase.gsub(' ', '_') == tag_slug }
    raise ActionController::RoutingError, "Not Found" unless @tag
    @posts = Post.all.select { |post| post.tags.include?(@tag) }
  end
end
