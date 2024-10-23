# frozen_string_literal: true

class Author < ApplicationRecord
  include Paginatable
  include Previewable

  has_and_belongs_to_many :books, inverse_of: :authors
  belongs_to :user, inverse_of: :author
end
