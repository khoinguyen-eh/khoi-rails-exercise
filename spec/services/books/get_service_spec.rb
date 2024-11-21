# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::GetService, type: :service do
  let!(:book1) { create(:book, rating: 4.0) }
  let!(:book2) { create(:book, rating: 5.0) }
  let!(:book3) { create(:book, rating: 3.5) }

  describe 'retrieves all books' do
    it 'returns all books when no pagination or top_rated options are provided' do
      service = described_class.new
      result = service.call

      expect(result).to include(book1, book2, book3)
    end
  end

  describe 'retrieves top rated books' do
    it 'returns books with rating above the specified minimum rating' do
      service = described_class.new(nil, nil, top_rated: { min_rating: 4.0 })
      result = service.call

      expect(result).to include(book1, book2)
      expect(result).not_to include(book3)
    end

    it 'returns top rated books limited by the specified limit' do
      service = described_class.new(nil, nil, top_rated: { limit: 1 })
      result = service.call

      expect(result.size).to eq(1)
      expect(result.first).to eq(book2)
    end
  end

  describe 'retrieves paginated books' do
    it 'returns paginated books when page and per_page are provided' do
      service = described_class.new(1, 2)
      result = service.call

      puts "result: #{result}"

      expect(result.size).to eq(2)
    end

    it 'returns the correct page of books' do
      service = described_class.new(2, 1)
      result = service.call

      expect(result.size).to eq(1)
      expect(result.first).to eq(book2)
    end
  end

  describe 'retrieves top rated and paginated books' do
    it 'returns top rated books with pagination' do
      service = described_class.new(1, 1, top_rated: { min_rating: 4.0 })
      result = service.call

      expect(result.size).to eq(1)
      expect(result.first).to eq(book2)
    end
  end
end
