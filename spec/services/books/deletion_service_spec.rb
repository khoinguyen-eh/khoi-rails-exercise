# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::DeletionService, type: :service do
  let(:creator) { create(:user) }
  let(:author) { create(:author) }
  let(:book) { create(:book, authors: [author], user: creator) }
  let(:another_book) { create(:book) }

  describe 'successful book deletion' do
    it 'deletes the book and clears author associations' do
      allow(creator.books).to receive(:find).with(book.id).and_return(book)

      service = described_class.new(creator, book.id)
      result = service.call

      expect(service).to be_success
      expect(result).to be_destroyed
      expect(book.authors).to be_empty
    end
  end

  describe 'book deletion with errors' do
    it 'does not delete the book if there are associated errors' do
      allow(creator.books).to receive(:find).with(book.id).and_return(book)
      allow(book).to receive(:destroy).and_return(false)
      allow(book).to receive(:errors).and_return(ActiveModel::Errors.new(book).tap { |e|
        e.add(:base, 'Deletion failed')
      })

      service = described_class.new(creator, book.id)
      result = service.call

      expect(service).not_to be_success
      expect(result).not_to be_destroyed
      expect(service.errors).to include('Deletion failed')
      expect(result.reload.authors).to include(author)
    end

    it 'adds error if book is not found' do
      service = described_class.new(creator, -1)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(ActiveRecord::RecordNotFound)
    end

    it 'does not find the book by another user' do
      service = described_class.new(creator, another_book.id)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(ActiveRecord::RecordNotFound)
    end

    it 'does not delete the book if creator is nil' do
      service = described_class.new(nil, book.id)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('creator is required'))
    end
  end
end
