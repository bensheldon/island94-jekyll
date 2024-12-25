require 'rails_helper'

RSpec.describe 'Site' do
  it 'renders index.html' do
    visit '/'
    expect(page.status_code).to eq 200
    expect(page).to have_title 'Island94'
  end
end
