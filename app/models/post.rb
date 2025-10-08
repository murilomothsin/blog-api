class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  validates :title, :body, :ip, presence: true


  # Scope to get posts with their average ratings
  scope :with_average_ratings, -> {
    left_joins(:ratings)
    .select("posts.id, posts.title, posts.body, CAST(AVG(ratings.value) AS DECIMAL(10, 2)) AS avg_rating")
    .group("posts.id")
    .order("avg_rating DESC NULLS LAST")
  }

  def average_rating
    ratings.average(:value)&.round(2) || 0.0
  end

  def ratings_count
    ratings.count
  end
end
