# frozen_string_literal: true

module Books
  class UpdateService < ::ServiceBase
    def initialize(creator, book_id, update_params)
      super
      @creator = creator
      @book_id = book_id
      @update_params = update_params
    end

    def call
      if creator.nil?
        add_error('creator is required')
        return
      end

      book = creator.books.find(book_id)
      book.assign_attributes(update_params)
      add_errors(book.errors) unless book.save

      book
    rescue ActiveRecord::RecordNotFound => e
      add_error(e)
    end

    private

    attr_reader :creator, :book_id, :update_params
  end
end
