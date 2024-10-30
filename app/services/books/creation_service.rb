# frozen_string_literal: true

module Books
  class CreationService < ::ServiceBase
    def initialize(creator, book_params)
      super
      @creator = creator
      @book_params = book_params
    end

    def call
      if creator.nil?
        add_error('creator is required')
        return
      end

      book = creator.books.create(book_params)
      add_errors(book.errors) unless book.persisted?

      book
    rescue ActiveRecord::RecordNotFound => e
      add_error(e)
    end

    private

    attr_reader :book_params, :creator
  end
end
