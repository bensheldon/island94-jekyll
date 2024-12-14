class PagesController < ApplicationController
  layout false, only: :redirect

  def about
  end

  def archives
    @posts = Post.all.reverse
  end

  def books
  end

  def tags
    @posts = Post.all
  end

  def feed
    @posts = Post.all.reverse.take(10)
  end

  def redirect
    @to = "/" + Redirect.all[params[:path]]
  end
end
