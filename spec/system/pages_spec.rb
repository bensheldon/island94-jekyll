require "rails_helper"

RSpec.describe "Pages", type: :system do
  it "visits the homepage" do
    visit "/"
    expect(page).to have_title 'Island94'
  end
end
