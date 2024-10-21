Rails.application.routes.draw do
  root "posts#index"
  get "/posts/:title", to: "posts#show", as: :post
end
