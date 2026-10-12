# frozen_string_literal: true
class PagesController < ApplicationController
  layout(lambda do
    if action_name == 'feed'
      nil
    else
      "narrow"
    end
  end)

  def about
  end

  def archives
    @posts = Post.published.reverse
  end

  def books
  end

  def tags
    @posts = Post.published
  end

  def feed
    @posts = Post.published.reverse.take(10)
  end

  before_action :build_search_index, only: :search

  def search
    respond_to do |format|
      format.html
      format.json
    end
  end

  private

  def build_search_index
    Pagefind.build
  end
end
