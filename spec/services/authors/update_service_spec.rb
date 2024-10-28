# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authors::UpdateService, type: :service do
  let(:user) { create(:user) }
  let(:author) { create(:author, user: user) }
  let(:valid_book) { create(:book) }
  let(:update_params) { { pen_name: 'Pen Name', bio: 'Lorem ipsum' } }
  let(:another_author) { create(:author) }

  describe 'successful author update' do
    it 'updates an author with valid params' do
      service = described_class.new(user, author.id, update_params)
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.pen_name).to eq('Pen Name')
      expect(updated_author.bio).to eq('Lorem ipsum')
    end

    it 'updates the author with valid book_ids' do
      service = described_class.new(user, author.id, update_params.merge(book_ids: [valid_book.id]))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to include(valid_book)
    end

    it 'updates the author with empty book_ids' do
      service = described_class.new(user, author.id, update_params.merge(book_ids: []))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to be_empty
    end

    it 'updates the author with books' do
      service = described_class.new(user, author.id, update_params.merge(books: [valid_book]))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to include(valid_book)
    end

    it 'updates the author with empty books' do
      service = described_class.new(user, author.id, update_params.merge(books: []))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to be_empty
    end
  end

  describe 'author update with errors' do
    it 'does not update the author with invalid book_ids' do
      service = described_class.new(user, author.id, update_params.merge(book_ids: [valid_book.id + 1]))
      service.call

      expect(service).not_to be_success
    end

    it 'does not update the author with invalid params' do
      invalid_params = { pen_name: '', bio: '' }
      service = described_class.new(user, author.id, invalid_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).not_to be_empty
    end

    it 'adds error if author is not found' do
      service = described_class.new(user, -1, update_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(ActiveRecord::RecordNotFound)
    end

    it 'does not find the author by another user' do
      service = described_class.new(user, another_author.id, update_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(ActiveRecord::RecordNotFound)
    end

    it 'does not update the author if user is nil' do
      service = described_class.new(nil, author.id, update_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('creator is required'))
    end
  end
end
