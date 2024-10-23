# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Previewable, type: :model do
  let(:dummy_model) do
    Class.new(ApplicationRecord) do
      self.table_name = 'temporary_books'
      include Previewable
    end
  end

  before do
    ActiveRecord::Base.connection.begin_transaction(joinable: false)

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE TEMPORARY TABLE temporary_books (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255)
      ) ON COMMIT DROP;
    SQL

    10.times { |i| dummy_model.create!(title: "Book #{i}") }
  end

  after do
    ActiveRecord::Base.connection.rollback_transaction
  end

  describe '.preview' do
    it 'returns the default number of items' do
      result = dummy_model.preview
      expect(result.size).to eq(5)
    end

    it 'returns the specified number of items' do
      result = dummy_model.preview(lim: 3)
      expect(result.size).to eq(3)
    end

    it 'returns all items if limit is greater than total items' do
      result = dummy_model.preview(lim: 15)
      expect(result.size).to eq(10)
    end

    it 'returns no items if limit is zero' do
      result = dummy_model.preview(lim: 0)
      expect(result.size).to eq(0)
    end

    it 'returns no items if limit is negative' do
      result = dummy_model.preview(lim: -5)
      expect(result.size).to eq(0)
    end
  end
end
