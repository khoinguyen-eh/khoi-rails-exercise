# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Paginatable, type: :model do
  let(:dummy_model) do
    Class.new(ApplicationRecord) do
      self.table_name = 'temporary_books'
      include Paginatable
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

    15.times { |i| dummy_model.create!(title: "Book #{i}") }
  end

  after do
    ActiveRecord::Base.connection.rollback_transaction
  end

  describe '.paginate' do
    it 'returns the correct number of items per page' do
      result = dummy_model.paginate(page: 1, per_page: 10)
      expect(result.size).to eq(10)
    end

    it 'returns the correct page of items' do
      result = dummy_model.paginate(page: 2, per_page: 10)
      expect(result.size).to eq(5)
    end

    it 'defaults to page 1 if page is less than 1' do
      result = dummy_model.paginate(page: 0, per_page: 10)
      expect(result.size).to eq(10)
    end

    it 'defaults to 10 items per page if per_page is less than 1' do
      result = dummy_model.paginate(page: 1, per_page: 0)
      expect(result.size).to eq(10)
    end
  end

  describe '.paginated_result' do
    it 'returns the correct pagination metadata' do
      result = dummy_model.paginated_result(page: 1, per_page: 10)
      expect(result[:page_index]).to eq(1)
      expect(result[:item_per_page]).to eq(10)
      expect(result[:total_pages]).to eq(2)
      expect(result[:total_items]).to eq(15)
    end

    it 'calculates total pages correctly' do
      result = dummy_model.paginated_result(page: 1, per_page: 10)
      expect(result[:total_pages]).to eq(2)
    end

    it 'defaults to page 1 if page is less than 1' do
      result = dummy_model.paginated_result(page: 0, per_page: 10)
      expect(result[:page_index]).to eq(1)
    end

    it 'defaults to 10 items per page if per_page is less than 1' do
      result = dummy_model.paginated_result(page: 1, per_page: 0)
      expect(result[:item_per_page]).to eq(10)
    end

    it 'returns the correct total items when overriding' do
      result = dummy_model.paginated_result(page: 1, per_page: 10, total_items: 5)
      expect(result[:total_items]).to eq(5)
      expect(result[:total_pages]).to eq(1)
    end
  end
end
