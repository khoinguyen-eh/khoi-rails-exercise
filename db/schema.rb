# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_241_021_072_243) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "pen_name"
    t.string "bio"
    t.boolean "is_verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "authors_books", id: false, force: :cascade do |t|
    t.bigint "author_id", null: false
    t.bigint "book_id", null: false
    t.index %w[author_id book_id], name: "index_authors_books_on_author_id_and_book_id", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "isbn", null: false
    t.string "name"
    t.string "description"
    t.decimal "rating", precision: 3, scale: 2
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.boolean "gender"
    t.datetime "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "authors", "users"
end
