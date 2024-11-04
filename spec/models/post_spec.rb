require_relative "../rails_helper"

RSpec.describe Post, type: :model do
  describe '.load_all' do
    it 'loads all posts from _posts directory' do
      result = Post.all

      expect(result.size).to be > 1
      expect(result.first).to be_a(Post)
      expect(result.first.title).to eq("Pool Soup")
    end
  end
end
