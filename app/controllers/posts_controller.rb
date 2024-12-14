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
end
