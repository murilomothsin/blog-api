require 'rails_helper'

RSpec.describe Post, type: :model do
  # Associations
  it { should belong_to(:user) }
  it { should have_many(:ratings) }

  # Validations
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:ip) }

  describe 'scopes and instance methods' do
    let!(:post) { create(:post) }

    it 'calculates average_rating and ratings_count' do
      # create some ratings
      create(:rating, post: post, value: 5)
      create(:rating, post: post, value: 3)

      expect(post.ratings_count).to eq(2)
      expect(post.average_rating).to eq(4.0)
    end

    it 'with_average_ratings scope returns posts with avg_rating attribute' do
      create(:rating, post: post, value: 5)
      result = Post.with_average_ratings.limit(1).first

      expect(result).to respond_to(:avg_rating)
      # avg_rating may be a BigDecimal or string cast; ensure it's present
      expect(result.avg_rating).not_to be_nil
    end
  end
end
