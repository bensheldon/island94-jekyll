# frozen_string_literal: true
require "rails_helper"

RSpec.describe Editor::TextDiff do
  it "shows word-level changes, deletions before insertions" do
    expect(described_class.new("Yesterday I go to", "Yesterday I went to").changes).to eq [
      [:equal, "Yesterday I "], [:delete, "go"], [:insert, "went"], [:equal, " to"]
    ]
  end

  it "shows removed and changed punctuation" do
    expect(described_class.new("the the store", "the store").changes).to eq [[:equal, "the "], [:delete, "the "], [:equal, "store"]]
    expect(described_class.new("store, there", "store; their").changes).to eq [
      [:equal, "store"], [:delete, ","], [:insert, ";"], [:equal, " "], [:delete, "there"], [:insert, "their"]
    ]
  end
end
