# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'associations' do
    let(:author) { create(:author) }
    let(:book) { create(:book) }

    it { is_expected.to have_and_belong_to_many(:books) }
    it { is_expected.to belong_to(:user) }

    it "can have many books" do
      # Add a book to the author
      author.books << book

      expect(author.books).to include(book)
    end

    it "can have a user" do
      user = create(:user)
      author.user = user

      expect(author.user).to eq(user)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:pen_name) }
    it { is_expected.to validate_presence_of(:bio) }
  end
end
