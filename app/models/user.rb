# frozen_string_literal: true

class User < ApplicationRecord
  include Paginatable

  has_secure_password
  has_one :author, dependent: :destroy, inverse_of: :user

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :password, presence: true, length: { minimum: 8 }
end
