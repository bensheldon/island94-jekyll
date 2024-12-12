
Parklife.application.config.on_404 = :warn

Rails.application.routes.draw do
  root "posts#index"
  get "/posts/:page", to: "posts#index", constraints: { page: /\d+/ }, as: :posts

  # get "/posts/:title", to: "posts#show", as: :post, constraints: { title: /.*/, format: /html/  }
  get "/:month/:day/:slug", to: "posts#show", as: :post, constraints: { month: /\d*/, day: /\d*/, slug: /.*/, format: /html/ }

  get "about", to: "pages#about"
  get "archives", to: "pages#archives"
  get "books", to: "pages#books"
  get "tags", to: "pages#tags"
  get "feed.xml", to: "pages#feed"

  get "*path", to: "pages#redirect", constraints: ->(req) { req.path.sub(%r{\A/}, "").sub(%r{/\z}, "").in?(Redirect.all.keys) }

  direct :post do |post|
    "/#{post.published_at.year}/#{post.published_at.month.to_s.rjust(2, "0")}/#{post.slug}"
  end
end
