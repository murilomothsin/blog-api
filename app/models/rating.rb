class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :user_id, uniqueness: { scope: :post_id, message: "has already rated this post" }
  validates :value, presence: true
  validates_numericality_of :value, in: 1..5
end
