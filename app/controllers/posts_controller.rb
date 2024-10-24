class PostsController < ApplicationController
  def index
    @posts = Post.all.reverse.first(10)
  end

  def show
    @post = Post.all.find { |post| post.title == params[:title] }
  end
end
