require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  # Validation tests using shoulda-matchers
  describe 'validations' do
    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login).case_insensitive }
  end
end
