class BookmarksController < ApplicationController
  def index
    @bookmarks = Bookmark.all.sort_by(&:date).reverse
  end

  def show
    slug_param = params[:slug].sub(/\.[^.]*\z/, "").downcase
    @bookmark = Bookmark.all.find { |post| post.slug.downcase == slug_param }
    raise ActionController::RoutingError, "Not Found" unless @bookmark
  end
end
