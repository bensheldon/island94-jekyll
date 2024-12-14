Parklife.application.config.on_404 = :warn

Rails.application.routes.draw do
  root "posts#index"
  get "/posts/:page", to: "posts#index", constraints: { page: /\d+/ }, as: :posts
  get "/:year/:month/:slug", to: "posts#show", as: :slugged_post, constraints: { year: /\d*/, month: /\d*/, slug: /.*/, format: /html/ }
  direct :post do |post, options|
    route_for :slugged_post, post.published_at.year, post.published_at.month, post.slug, options
  end

  get "about", to: "pages#about"
  get "archives", to: "pages#archives"
  get "books", to: "pages#books"
  get "tags", to: "pages#tags"
  get "posts/tags/:tag_slug", to: "posts#tag", as: :tag
  get "search", to: "pages#search", format: :html
  get "search", to: "pages#search", format: :json

  get "feed.xml", to: "pages#feed"

  get "*path", to: "pages#redirect", constraints: ->(req) { req.path.sub(%r{\A/}, "").sub(%r{/\z}, "").in?(Redirect.all.keys) }
end
