# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::BookSerializer, type: :serializer do
  let(:author) { create(:author) }
  let(:book) { create(:book, authors: [author]) }
  let(:serializer) { described_class.new(book, scope: scope) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer).as_json }

  context 'when include_authors is id_only' do
    let(:scope) { { include_authors: 'id_only' } }

    it 'returns only author ids' do
      expect(serialization[:authors]).to eq([author.id])
    end
  end

  context 'when include_authors is id_and_pen_name' do
    let(:scope) { { include_authors: 'id_and_pen_name' } }

    it 'returns author ids and pen names' do
      expected = { id: author.id, pen_name: author.pen_name }.stringify_keys
      expect(serialization[:authors]).to eq([expected])
    end
  end

  context 'when include_authors is id_and_all_names' do
    let(:scope) { { include_authors: 'id_and_all_names' } }

    it 'returns author ids and all names' do
      expected = {
        id: author.id,
        first_name: author.user.first_name,
        last_name: author.user.last_name,
        pen_name: author.pen_name
      }.stringify_keys
      expect(serialization[:authors]).to eq([expected])
    end
  end

  context 'when include_authors is all' do
    let(:scope) { { include_authors: 'all' } }

    it 'returns full author details' do
      user = author.user
      expected = {
        id: author.id,
        pen_name: author.pen_name,
        bio: author.bio,
        is_verified: author.is_verified,
        user: {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          date_of_birth: user.date_of_birth.iso8601,
          gender: user.gender
        }.stringify_keys
      }.stringify_keys

      expect(serialization[:authors]).to eq([expected])
    end
  end

  context 'when include_authors is nil' do
    let(:scope) { { include_authors: nil } }

    it 'does not include authors' do
      expect(serialization).not_to have_key(:authors)
    end
  end
end
