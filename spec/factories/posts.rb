FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence(word_count: 2) }
    body { Faker::Lorem.paragraph(sentence_count: 2) }
    ip { Faker::Internet.ip_v4_address }
  end
end
