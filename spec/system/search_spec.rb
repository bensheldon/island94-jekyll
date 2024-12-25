require 'rails_helper'

RSpec.describe 'Searching', js: true do
  it 'can search for a result that is highlighted' do
    visit "/"
    fill_in 'q', with: "concrete sumo"
    find('#search-box').native.send_keys(:return)

    expect(page).to have_text 'The concrete sumo', wait: 10
  end
end
