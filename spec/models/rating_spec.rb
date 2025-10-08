require 'rails_helper'

RSpec.describe Rating, type: :model do
  # Association tests
  describe 'associations' do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end

  # Validation tests
  describe 'validations' do
    subject { build(:rating) }

    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value).is_in(1..5) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:post_id).with_message("has already rated this post") }
  end
end
