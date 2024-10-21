# frozen_string_literal: true

namespace :db do
  desc 'Populate tables with random data'
  task populate: :environment do
    number_of_users_and_authors = 10
    number_of_books = 20
    authors_per_book_range = (1..3)

    number_of_users_and_authors.times do
      user = User.create(
        email: Faker::Internet.email,
        password: Faker::Internet.password,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        gender: Faker::Boolean.boolean,
        date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65)
      )

      Author.create!(
        user: user,
        pen_name: Faker::Book.author,
        bio: Faker::Lorem.paragraph,
        is_verified: Faker::Boolean.boolean
      )
    end

    number_of_books.times do
      book = Book.create(
        isbn: Faker::Code.isbn,
        name: Faker::Book.title,
        published_at: Faker::Date.between(from: 10.years.ago, to: Time.zone.today),
        rating: Faker::Number.between(from: 0.0, to: 5.0),
        description: Faker::Lorem.paragraph
      )

      authors = Author.all.sample(rand(authors_per_book_range))
      book.authors << authors

      book.save
    end
  end
end
