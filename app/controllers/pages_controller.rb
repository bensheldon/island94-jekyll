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
    target = Redirect.all[params[:path]]
    case target
    when String then target
    when Post then post_path(target)
    else
      raise ActionController::RoutingError, "No redirect found for #{params[:path]}"
    end
    @to = target
  end

  def search
    respond_to do |format|
      format.html
      format.json
    end
  end
end
