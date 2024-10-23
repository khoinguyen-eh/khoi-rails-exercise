# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authors::DeletionService, type: :service do
  let(:book) { create(:book) }
  let(:author) { create(:author, books: [book]) }

  describe 'successful author deletion' do
    it 'deletes the author and clears book associations' do
      service = described_class.new(author)
      result = service.call

      expect(service).to be_success
      expect(result).to be_destroyed
      expect(author.books).to be_empty
    end
  end

  describe 'author deletion with errors' do
    it 'does not delete the author if there are associated errors' do
      allow(author).to receive(:destroy).and_return(false)
      allow(author).to receive(:errors).and_return(ActiveModel::Errors.new(author).tap { |e|
        e.add(:base, 'Deletion failed')
      })

      service = described_class.new(author)
      result = service.call

      expect(service).not_to be_success
      expect(result).not_to be_destroyed
      expect(service.errors).to include('Deletion failed')
    end
  end
end
