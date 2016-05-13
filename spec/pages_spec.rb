require_relative 'spec_helper'

describe 'Site' do
  it 'renders index.html' do
    visit '/index.html'
    expect(page.status_code).to eq 200
    expect(page).to have_title 'Island94.org'
  end
end
