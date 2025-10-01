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

puts "Creating a new post via POST request..."
users = 100.times.map { Faker::Internet.username }.uniq
ips = 50.times.map { Faker::Internet.ip_v4_address }.uniq
future1 = Concurrent::Promises.future do
  users[0..25].each do |user|
    2000.times do
      user_data = { login: user, post: { title: Faker::Book.title, body: Faker::Lorem.paragraph, ip: ips.sample } }.to_json
      system("curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts")
    end
  end
end

future2 = Concurrent::Promises.future do
  users[25..50].each do |user|
    2000.times do
      user_data = { login: user, post: { title: Faker::Book.title, body: Faker::Lorem.paragraph, ip: ips.sample } }.to_json
      system("curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts")
    end
  end
end

future3 = Concurrent::Promises.future do
  users[50..75].each do |user|
    2000.times do
      user_data = { login: user, post: { title: Faker::Book.title, body: Faker::Lorem.paragraph, ip: ips.sample } }.to_json
      system("curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts")
    end
  end
end

future4 = Concurrent::Promises.future do
  users[75..100].each do |user|
    2000.times do
      user_data = { login: user, post: { title: Faker::Book.title, body: Faker::Lorem.paragraph, ip: ips.sample } }.to_json
      system("curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts")
    end
  end
end

future = Concurrent::Promises.zip(future1, future2, future3, future4)
future.value!

# 200.times do
#   user_data = { login: Faker::Internet.username, post: { title: Faker::Book.title, body: Faker::Lorem.paragraph, ip: Faker::Internet.ip_v4_address } }.to_json
#   system("curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts")
# end


# user_data = { login: "john_doe", post: { title: "Test Post 1", body: "This is a test post.", ip: "192.168.1.2" } }.to_json
# system("curl -X POST -H 'Content-Type: application/json' -d '#{user_data}' http://web:3000/posts")
