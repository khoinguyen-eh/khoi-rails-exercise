# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::CreationService, type: :service do
  let(:author) { create(:author) }
  let(:book_params) do
    {
      isbn: '1234567890',
      name: 'Title',
      description: 'Lorem ipsum',
      published_at: Time.zone.now,
      rating: 4.5
    }
  end

  describe 'successful book creation' do
    it 'creates a book with valid params' do
      service = described_class.new(book_params)
      book = service.call

      expect(service).to be_success
      expect(book).to be_persisted
      expect(book.isbn).to eq('1234567890')
      expect(book.name).to eq('Title')
      expect(book.description).to eq('Lorem ipsum')
      expect(book.published_at).to be_present
      expect(book.rating).to eq(4.5)
    end

    it 'creates a book with valid params and author_ids' do
      book_params[:author_ids] = [author.id]
      service = described_class.new(book_params)
      book = service.call

      expect(service).to be_success
      expect(book).to be_persisted
      expect(book.authors).to eq([author])
    end

    it 'creates a book with valid params and authors' do
      book_params[:authors] = [author]
      service = described_class.new(book_params)
      book = service.call

      expect(service).to be_success
      expect(book).to be_persisted
      expect(book.authors).to eq([author])
    end
  end

  describe 'book creation with errors' do
    it 'does not create a book without a name' do
      service = described_class.new(book_params.except(:name))
      service.call

      expect(service).not_to be_success
    end

    it 'does not create a book with invalid author_ids' do
      invalid_author_id = author.id + 1
      book_params[:author_ids] = [invalid_author_id]
      service = described_class.new(book_params)
      service.call

      expect(service).not_to be_success
    end
  end
end
