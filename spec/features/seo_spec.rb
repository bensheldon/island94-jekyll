require 'rails_helper'

RSpec.describe 'SEO' do
  context 'when on frontpage' do
    it 'does not include robots meta tag' do
      visit '/'

      expect(page).not_to have_css 'meta[name="robots"]',
                                   visible: false
    end
  end

  context 'when on a post' do
    it 'does not include robots meta tag' do
      visit '/'
      within(:css, 'h1.post-title', match: :first) do
        click_link
      end

      expect(page.text).to include 'Island94.org'
      expect(page).not_to have_css 'meta[name="robots"]',
                                   visible: false
    end
  end

  context 'when on archive page' do
    it 'includes robots noindex,nofollow meta tag' do
      visit '/page/2/'

      expect(page).to have_css 'meta[name="robots"][content="noindex, follow"]',
                               visible: false
    end
  end

  context 'sitemap' do
    # Not compatible with latest versions of jekyll-sitemap plugin
    xit 'does not include archive pages' do
      visit 'sitemap.xml'

      sitemap = Nokogiri::XML page.body
      urls = sitemap.css('url loc').map(&:text)
      archive_urls = urls.grep(%r{/page/})

      expect(archive_urls).to be_empty
    end
  end
end
