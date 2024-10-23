# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::DeletionService, type: :service do
  let(:author) { create(:author) }
  let(:book) { create(:book, authors: [author]) }

  describe 'successful book deletion' do
    it 'deletes the book and clears author associations' do
      service = described_class.new(book)
      result = service.call

      expect(service).to be_success
      expect(result).to be_destroyed
      expect(book.authors).to be_empty
    end
  end

  describe 'book deletion with errors' do
    it 'does not delete the book if there are associated errors' do
      allow(book).to receive(:destroy).and_return(false)
      allow(book).to receive(:errors).and_return(ActiveModel::Errors.new(book).tap { |e|
        e.add(:base, 'Deletion failed')
      })

      service = described_class.new(book)
      result = service.call

      expect(service).not_to be_success
      expect(result).not_to be_destroyed
      expect(service.errors).to include('Deletion failed')
    end
  end
end
