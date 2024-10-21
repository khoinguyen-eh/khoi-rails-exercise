# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    isbn { Faker::Code.isbn }
    name { Faker::Book.title }
    published_at { Faker::Date.between(from: 10.years.ago, to: Time.zone.today) }
    rating { Faker::Number.between(from: 0.0, to: 5.0) }
    description { Faker::Lorem.paragraph }
    authors { [] }
  end
end
