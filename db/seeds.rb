# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'concurrent-ruby'


def save_ids(response_data)
  user_id = response_data.dig("data", "user", "id")
  post_id = response_data.dig("data", "post", "id")

  @user_ids << user_id if user_id && !@user_ids.include?(user_id)
  @post_ids << post_id if post_id && !@post_ids.include?(post_id)
end

def create_post(user, ips)
  5.times do
    user_data = { login: user, post: { title: Faker::Book.title, body: Faker::Lorem.paragraph, ip: ips.sample } }.to_json
    response = `curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts`
    response_data = JSON.parse(response) rescue {}

    save_ids(response_data)
  end
end

def create_rating(post_id, user_id, value)
  rating_data = { rating: { user_id: user_id, value: value } }.to_json
  response = `curl -X POST -H 'Content-Type: application/json' -d '#{rating_data}' http://web:3000/posts/#{post_id}/rating`
  response_data = JSON.parse(response) rescue {}

  response_data
end

puts "Creating a new post via POST request..."
@user_ids = []
@post_ids = []
users = 100.times.map { Faker::Internet.username }.uniq
ips = 50.times.map { Faker::Internet.ip_v4_address }.uniq

future1 = Concurrent::Promises.future do
  users[0..25].each do |user|
    create_post(user, ips)
  end
end

future2 = Concurrent::Promises.future do
  users[25..50].each do |user|
    create_post(user, ips)
  end
end

future3 = Concurrent::Promises.future do
  users[50..75].each do |user|
    create_post(user, ips)
  end
end

future4 = Concurrent::Promises.future do
  users[75..100].each do |user|
    create_post(user, ips)
  end
end

future = Concurrent::Promises.zip(future1, future2, future3, future4)
future.value!

puts "Created #{@user_ids.size} users and #{@post_ids.size} posts."

puts "Creating ratings via POST request..."
@errors = 0
max_ratings = (@post_ids.size * 0.75).to_i

@post_ids.sample(max_ratings).each do |post_id|
  user = @user_ids.sample
  rating_value = rand(1..5)
  response = create_rating(post_id, user, rating_value)
  @errors += 1 unless response.dig("data", "avg_rating")

  user = @user_ids.sample
  rating_value = rand(1..5)
  response = create_rating(post_id, user, rating_value)
  @errors += 1 unless response.dig("data", "avg_rating")
end

puts "Created ratings for #{max_ratings} posts with #{@errors} errors."
