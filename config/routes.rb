Rails.application.routes.draw do
  root "posts#index"
  get "/posts/:title", to: "posts#show"

  direct :post do |post|
    "/posts/#{post.title}"
  end
end
