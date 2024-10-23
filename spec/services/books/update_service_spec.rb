# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::UpdateService, type: :service do
  let(:book) { create(:book) }
  let(:valid_author) { create(:author) }
  let(:update_params) { { isbn: '0987654321', name: 'New Title', description: 'Updated lorem ipsum', rating: 4.8 } }

  describe 'successful book update' do
    it 'updates a book with valid params' do
      service = described_class.new(book, update_params)
      updated_book = service.call

      expect(service).to be_success
      expect(updated_book.isbn).to eq('0987654321')
      expect(updated_book.name).to eq('New Title')
      expect(updated_book.description).to eq('Updated lorem ipsum')
      expect(updated_book.rating).to eq(4.8)
    end

    it 'updates the book with valid author_ids' do
      service = described_class.new(book, update_params.merge(author_ids: [valid_author.id]))
      updated_book = service.call

      expect(service).to be_success
      expect(updated_book.authors).to include(valid_author)
    end

    it 'updates the book with empty author_ids' do
      service = described_class.new(book, update_params.merge(author_ids: []))
      updated_book = service.call

      expect(service).to be_success
      expect(updated_book.authors).to be_empty
    end

    it 'updates the book with authors' do
      service = described_class.new(book, update_params.merge(authors: [valid_author]))
      updated_book = service.call

      expect(service).to be_success
      expect(updated_book.authors).to include(valid_author)
    end

    it 'updates the book with empty authors' do
      service = described_class.new(book, update_params.merge(authors: []))
      updated_book = service.call

      expect(service).to be_success
      expect(updated_book.authors).to be_empty
    end
  end

  describe 'book update with errors' do
    it 'does not update the book with invalid author_ids' do
      service = described_class.new(book, update_params.merge(author_ids: [valid_author.id + 1]))
      service.call

      expect(service).not_to be_success
    end

    it 'does not update the book with invalid params' do
      invalid_params = { isbn: '', name: '', description: '', rating: -1 }
      service = described_class.new(book, invalid_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).not_to be_empty
    end
  end
end
