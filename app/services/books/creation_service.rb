# frozen_string_literal: true

module Books
  class CreationService < ::ServiceBase
    def initialize(book_params)
      super
      @book_params = book_params
    end

    def call
      book = Book.new(book_params)
      add_errors(book.errors) unless book.save

      book
    rescue ActiveRecord::RecordNotFound => e
      add_error(e.message)
    end

    private

    attr_reader :book_params
  end
end
