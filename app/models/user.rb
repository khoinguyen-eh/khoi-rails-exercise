# frozen_string_literal: true

class User < ApplicationRecord
  include Paginatable

  has_secure_password
  has_many :authors, dependent: :destroy, inverse_of: :user
  has_many :books, dependent: :destroy, inverse_of: :user
  has_many :agent_import_workflows, dependent: :destroy, inverse_of: :author, foreign_key: 'author_id'

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :password, presence: true, length: { minimum: 8 }, if: :password_required?

  private

  def password_required?
    new_record? || password.present?
  end
end
