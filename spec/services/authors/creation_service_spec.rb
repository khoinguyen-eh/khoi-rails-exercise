# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authors::CreationService, type: :service do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:author_params) { { pen_name: 'Pen Name', bio: 'Lorem ipsum', user_id: user.id } }

  describe 'successful author creation' do
    it 'creates an author with valid params' do
      service = described_class.new(author_params)
      author = service.call

      expect(service).to be_success
      expect(author).to be_persisted
      expect(author.pen_name).to eq('Pen Name')
      expect(author.bio).to eq('Lorem ipsum')
      expect(author.user_id).to eq(user.id)
    end

    it 'creates an author with valid params and book_ids' do
      author_params[:book_ids] = [book.id]
      service = described_class.new(author_params)
      author = service.call

      expect(service).to be_success
      expect(author).to be_persisted
      expect(author.books).to eq([book])
    end

    it 'creates an author with valid params and books' do
      author_params[:books] = [book]
      service = described_class.new(author_params)
      author = service.call

      expect(service).to be_success
      expect(author).to be_persisted
      expect(author.books).to eq([book])
    end
  end

  describe 'author creation with errors' do
    it 'does not create an author without user or user_id' do
      service = described_class.new(author_params.except(:user_id))
      service.call

      expect(service).not_to be_success
    end

    it 'does not create an author with invalid book_ids' do
      invalid_book_id = book.id + 1
      author_params[:book_ids] = [invalid_book_id]
      service = described_class.new(author_params)
      service.call

      expect(service).not_to be_success
    end
  end
end
