# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authors::GetService, type: :service do
  let!(:author1) { create(:author) }
  let!(:author2) { create(:author) }
  let!(:author3) { create(:author) }

  describe 'retrieves all authors' do
    it 'returns all authors when no pagination or top_rated options are provided' do
      service = described_class.new
      result = service.call

      expect(result).to include(author1, author2, author3)
    end
  end

  describe 'retrieves paginated authors' do
    it 'returns paginated authors when page and per_page are provided' do
      service = described_class.new(1, 2)
      result = service.call

      expect(result.size).to eq(2)
    end

    it 'returns the correct page of authors' do
      service = described_class.new(2, 1)
      result = service.call

      expect(result.size).to eq(1)
      expect(result.first).to eq(author2)
    end
  end
end
