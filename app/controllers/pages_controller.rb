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
  end

  def redirect
    @to = Redirect.all[params[:path]]
  end
end
