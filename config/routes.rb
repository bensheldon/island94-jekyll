
Parklife.application.config.on_404 = :warn

Rails.application.routes.draw do
  root "posts#index"
  get "/posts/:title", to: "posts#show", as: :post, constraints: { title: /.*/, format: /html/  }

  get "about", to: "pages#about"
  get "archives", to: "pages#archives"
  get "books", to: "pages#books"
  get "tags", to: "pages#tags"
  get "feed.xml", to: "pages#feed"

  get "*path", to: "pages#redirect", constraints: ->(req) { req.path.sub(%r{^/}, "").in?(Redirect.all.keys) }

  direct :post do |post|
    "/posts/#{post.slug}"
  end
end
