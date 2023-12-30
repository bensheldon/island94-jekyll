source 'https://rubygems.org'
ruby File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip

gem 'activesupport'
gem 'jekyll'
gem 'jekyll-coffeescript'
gem 'jekyll-paginate'
gem 'jekyll-redirect-from'
gem 'kramdown-parser-gfm'
gem 'jekyll-sitemap'
gem 'jekyll-compose'
gem 'octokit'

# for related_posts with --lsi
gem 'classifier-reborn'
gem 'gsl', github: 'SciRuby/rb-gsl', branch: 'master'

# for fetching bookmarks
gem "metainspector", "~> 5.15"

group :development, :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'pry'
  gem 'rake'
  gem 'rack', '~> 2.2'
  gem 'lanyon'
  gem 'rspec'
  gem 'webrick'
end
