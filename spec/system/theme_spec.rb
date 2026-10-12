# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Bootstrap color mode theme', :js do
  it 'defaults to auto, reflects the active theme in the UI, and persists across reloads' do
    visit "/"

    # Defaults to "auto" with no theme stored, resolved to light (no OS dark preference in test env).
    expect(page).to have_css 'html[data-bs-theme="light"]'
    expect(page).to have_css '[data-theme-target="activeIcon"].bi-circle-half'
    expect(page).to have_css '[data-bs-theme-value="auto"][aria-pressed="true"]', visible: :all
    expect(page).to have_css '[data-bs-theme-value="light"][aria-pressed="false"]', visible: :all
    expect(page).to have_css '[data-bs-theme-value="dark"][aria-pressed="false"]', visible: :all
    expect(page).to have_css '[data-theme-target="switcher"][aria-label="Theme (auto)"]'

    # Switch to Dark
    click_on "Theme"
    click_on "Dark"

    expect(page).to have_css 'html[data-bs-theme="dark"]'
    expect(page).to have_css '[data-theme-target="activeIcon"].bi-moon-stars-fill'
    expect(page).to have_css '[data-bs-theme-value="dark"][aria-pressed="true"]', visible: :all
    expect(page).to have_css '[data-bs-theme-value="auto"][aria-pressed="false"]', visible: :all
    expect(page).to have_css '[data-bs-theme-value="light"][aria-pressed="false"]', visible: :all
    expect(page).to have_css '[data-theme-target="switcher"][aria-label="Theme (dark)"]'
    expect(page).to have_css '[data-theme-target="switcher"]:focus'

    # Persists across reload, including the icon reflecting the stored setting (not just the resolved DOM theme).
    visit "/"
    expect(page).to have_css 'html[data-bs-theme="dark"]'
    expect(page).to have_css '[data-theme-target="activeIcon"].bi-moon-stars-fill'
    expect(page).to have_css '[data-bs-theme-value="dark"][aria-pressed="true"]', visible: :all

    # Switch to Light
    click_on "Theme"
    click_on "Light"

    expect(page).to have_css 'html[data-bs-theme="light"]'
    expect(page).to have_css '[data-theme-target="activeIcon"].bi-sun'
    expect(page).to have_css '[data-bs-theme-value="light"][aria-pressed="true"]', visible: :all
    expect(page).to have_css '[data-bs-theme-value="dark"][aria-pressed="false"]', visible: :all
    expect(page).to have_css '[data-theme-target="switcher"][aria-label="Theme (light)"]'

    # Switch back to Auto
    click_on "Theme"
    click_on "Auto"

    expect(page).to have_css 'html[data-bs-theme="light"]'
    expect(page).to have_css '[data-theme-target="activeIcon"].bi-circle-half'
    expect(page).to have_css '[data-bs-theme-value="auto"][aria-pressed="true"]', visible: :all
    expect(page).to have_css '[data-bs-theme-value="light"][aria-pressed="false"]', visible: :all
    expect(page).to have_css '[data-theme-target="switcher"][aria-label="Theme (auto)"]'

    visit "/"
    expect(page).to have_css 'html[data-bs-theme="light"]'
    expect(page).to have_css '[data-theme-target="activeIcon"].bi-circle-half'
    expect(page).to have_css '[data-bs-theme-value="auto"][aria-pressed="true"]', visible: :all
  end
end
