# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authors::DeletionService, type: :service do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:author) { create(:author, user: user, books: [book]) }
  let(:another_author) { create(:author) }

  describe 'successful author deletion' do
    it 'deletes the author and clears book associations' do
      allow(user.authors).to receive(:find).with(author.id).and_return(author)

      service = described_class.new(user, author.id)
      result = service.call

      expect(service).to be_success
      expect(result).to be_destroyed
      expect(author.books).to be_empty
    end
  end

  describe 'author deletion with errors' do
    it 'does not delete the author if there are associated errors' do
      allow(user.authors).to receive(:find).with(author.id).and_return(author)
      allow(author).to receive(:destroy).and_return(false)
      allow(author).to receive(:errors).and_return(ActiveModel::Errors.new(author).tap { |e|
        e.add(:base, 'Deletion failed')
      })

      service = described_class.new(user, author.id)
      result = service.call

      expect(service).not_to be_success
      expect(result).not_to be_destroyed
      expect(service.errors).to include('Deletion failed')
      expect(author.reload.books).to include(book)
    end

    it 'adds error if author is not found' do
      service = described_class.new(user, -1)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(ActiveRecord::RecordNotFound)
    end

    it 'does not find the author by another user' do
      service = described_class.new(user, another_author.id)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(ActiveRecord::RecordNotFound)
    end

    it 'does not delete the author if user is nil' do
      service = described_class.new(nil, author.id)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('creator is required'))
    end
  end
end
