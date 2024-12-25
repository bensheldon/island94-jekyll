class RedirectsController < ApplicationController
  layout false, only: :show

  def index
    @redirects = Redirect.all
  end

  def show
    target = Redirect.all[params[:path]]

    @redirect = case target
    when String then "/" + target
    when Post then post_path(target)
    else
      raise ActionController::RoutingError, "No redirect found for #{params[:path]}"
    end
  end
end
