# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe 'associations' do
    it { is_expected.to have_one(:author).inverse_of(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }

    it "allows valid email addresses" do
      valid_emails = %w[test@example.com user.name@domain.co user+tag@domain.org john_doe@example.edu]

      valid_emails.each do |email|
        user = described_class.new(email: email)
        user.valid?
        expect(user.errors[:email]).to be_empty, "Expected #{email} to be valid"
      end
    end

    it "does not allow invalid email addresses" do
      invalid_emails = %w[test@example,com user.name@domain. user+tag@domain. john_doe@example.]

      invalid_emails.each do |email|
        user = described_class.new(email: email)
        user.valid?
        expect(user.errors[:email]).to include("is invalid"), "Expected #{email} to be invalid"
      end
    end

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
  end
end
