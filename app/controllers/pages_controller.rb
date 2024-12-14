class PagesController < ApplicationController
  layout false, only: :redirect

  def about
  end

  def archives
  end

  def books
  end

  def tags
  end

  def feed
    @posts = Post.all.reverse.take(10)
  end

  def redirect
    @to = "/" + Redirect.all[params[:path]]
  end
end
