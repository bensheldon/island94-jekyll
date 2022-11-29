require_relative '../spec_helper'

RSpec.describe 'Searching', js: true do
  it 'can search for a result that is highlighted' do
    visit "/"
    fill_in 'q', with: "concrete sumo"
    find('#search-box').native.send_keys(:return)

    expect(page).to have_link 'The concrete sumo'
    expect(page.html).to include "<mark>Concrete</mark> <mark>Sumo</mark>"
  end
end
