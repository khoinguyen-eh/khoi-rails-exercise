# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'associations' do
    let(:author) { create(:author) }
    let(:book) { create(:book) }

    it { should have_and_belong_to_many(:authors) }

    it "can have many authors" do
      # Add an author to the book
      book.authors << author

      expect(book.authors).to include(author)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:isbn) }
    it { should validate_presence_of(:published_at) }

    it {
      should validate_numericality_of(:rating).is_greater_than_or_equal_to(0.0).is_less_than_or_equal_to(5.0)
    }
  end
end
