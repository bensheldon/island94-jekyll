require "rails_helper"

RSpec.describe "Pages" do
  it "visits the homepage" do
    visit "/"
    expect(page).to have_title 'Island94'
  end
end
