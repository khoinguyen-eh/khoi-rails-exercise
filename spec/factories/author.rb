# frozen_string_literal: true

FactoryBot.define do
  factory :author do
    pen_name { Faker::Book.author }
    bio { Faker::Lorem.paragraph }
    is_verified { Faker::Boolean.boolean }
    books { [] }

    association :user, factory: :user

    factory :author_with_books do
      transient do
        books_count { 5 }
      end

      after(:create) do |author, evaluator|
        create_list(:book, evaluator.books_count, authors: [author])
      end
    end
  end
end
