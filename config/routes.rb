Parklife.application.config.on_404 = :warn

Rails.application.routes.draw do
  get "*path", to: "redirects#show", constraints: ->(req) { Redirect.all.key? req.path.sub(%r{\A/}, "").sub(%r{/\z}, "") }

  root "posts#index"
  get "/posts/:page", to: "posts#index", constraints: { page: /\d+/ }, as: :posts
  get "/:year/:month/:slug", to: "posts#show", as: :slugged_post, constraints: { year: /\d*/, month: /\d*/, slug: /.*/, format: /html/ }
  direct :post do |post, options|
    route_for :slugged_post, post.published_at.year, post.published_at.month, post.slug, **options
  end

  get "about", to: "pages#about"
  get "archives", to: "pages#archives"
  get "books", to: "pages#books"
  get "tags", to: "pages#tags"
  get "posts/tags/:tag_slug", to: "posts#tag", as: :tag
  get "search", to: "pages#search", format: :html
  get "search", to: "pages#search", format: :json

  get "feed", to: "pages#feed", as: :feed, format: :xml

  get "redirects", to: "redirects#index"

  resources :bookmarks, only: [:index]
  get "/bookmarks/:year/:month/:slug", to: "bookmarks#show", as: :slugged_bookmark, constraints: { year: /\d*/, month: /\d*/, slug: /.*/, format: /html/ }

  direct :bookmark do |bookmark, options|
    route_for :slugged_bookmark, year: bookmark.date.year, month: bookmark.date.month, slug: bookmark.slug, **options
  end
end
