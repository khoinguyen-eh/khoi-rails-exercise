# frozen_string_literal: true

class Book < ApplicationRecord
  include Paginatable
  include Previewable

  has_and_belongs_to_many :authors, inverse_of: :books

  validates :isbn, presence: true, uniqueness: true
  validates :name, presence: true
  validates :published_at, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 5.0 }
end
