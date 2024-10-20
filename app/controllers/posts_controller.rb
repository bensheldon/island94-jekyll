class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.all.find { |post| post.title == params[:title] }
  end
end
