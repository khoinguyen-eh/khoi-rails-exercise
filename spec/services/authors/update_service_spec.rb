# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authors::UpdateService, type: :service do
  let(:author) { create(:author) }
  let(:valid_book) { create(:book) }
  let(:update_params) { { pen_name: 'Pen Name', bio: 'Lorem ipsum' } }
  let(:user) { create(:user) }

  describe 'successful author update' do
    it 'updates an author with valid params' do
      service = described_class.new(author, update_params)
      author = service.call

      expect(service).to be_success
      expect(author.pen_name).to eq('Pen Name')
      expect(author.bio).to eq('Lorem ipsum')
    end

    it 'updates the author with valid book_ids' do
      service = described_class.new(author, update_params.merge(book_ids: [valid_book.id]))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to include(valid_book)
    end

    it 'updates the author with empty book_ids' do
      service = described_class.new(author, update_params.merge(book_ids: []))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to be_empty
    end

    it 'updates the author with books' do
      service = described_class.new(author, update_params.merge(books: [valid_book]))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to include(valid_book)
    end

    it 'updates the author with empty books' do
      service = described_class.new(author, update_params.merge(books: []))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.books).to be_empty
    end

    it 'updates the author with user_id' do
      service = described_class.new(author, update_params.merge(user_id: user.id))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.user).to eq(user)
    end

    it 'updates the author with user' do
      service = described_class.new(author, update_params.merge(user: user))
      updated_author = service.call

      expect(service).to be_success
      expect(updated_author.user).to eq(user)
    end
  end

  describe 'author update with errors' do
    it 'does not update the author with invalid book_ids' do
      service = described_class.new(author, update_params.merge(book_ids: [valid_book.id + 1]))
      service.call

      expect(service).not_to be_success
    end

    it 'does not update the author with invalid params' do
      invalid_params = { pen_name: '', bio: '', user_id: user.id + 2 }
      service = described_class.new(author, invalid_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).not_to be_empty
    end
  end
end
