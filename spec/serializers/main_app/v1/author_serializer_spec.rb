# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::AuthorSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:author) { create(:author, user: user, books: [book]) }
  let(:serializer) { described_class.new(author, scope: scope) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer).as_json }

  context 'when include_books is id_only' do
    let(:scope) { { include_books: 'id_only' } }

    it 'returns only book ids' do
      expect(serialization[:books]).to eq([book.id])
    end
  end

  context 'when include_books is id_and_name' do
    let(:scope) { { include_books: 'id_and_name' } }

    it 'returns book ids and names' do
      expected = { id: book.id, name: book.name }.stringify_keys
      expect(serialization[:books]).to eq([expected])
    end
  end

  context 'when include_books is all' do
    let(:scope) { { include_books: 'all' } }

    it 'returns full book details' do
      expected = {
        id: book.id,
        isbn: book.isbn,
        name: book.name,
        description: book.description,
        published_at: book.published_at.iso8601,
        rating: book.rating.to_s
      }.stringify_keys
      expect(serialization[:books]).to eq([expected])
    end
  end

  context 'when include_books is false' do
    let(:scope) { { include_books: false } }

    it 'does not include books' do
      expect(serialization).not_to have_key(:books)
    end
  end

  context 'when include_user is nil' do
    let(:scope) { { include_user: nil } }

    it 'does not include user details' do
      expect(serialization).not_to have_key(:user)
    end
  end

  context 'when include_user is true' do
    let(:scope) { { include_user: true } }

    it 'returns user details' do
      expected = {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        gender: user.gender,
        date_of_birth: user.date_of_birth.iso8601
      }
      expect(serialization[:user]).to eq(expected)
    end
  end
end
