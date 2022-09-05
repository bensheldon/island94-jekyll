source 'https://rubygems.org'
ruby File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip

gem 'jekyll'
gem 'jekyll-coffeescript'
gem 'jekyll-paginate'
gem 'jekyll-redirect-from'
gem 'kramdown-parser-gfm'
gem 'jekyll-sitemap'
gem 'jekyll-compose'

# for related_posts with --lsi
gem 'classifier-reborn'
gem 'gsl', github: 'SciRuby/rb-gsl', branch: 'master'

group :development, :test do
  gem 'capybara'
  gem 'pry'
  gem 'rake'
  gem 'rack-jekyll', github: 'adaoraul/rack-jekyll'
  gem 'rspec'
  gem 'webrick'
end
