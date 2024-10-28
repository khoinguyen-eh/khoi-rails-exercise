# frozen_string_literal: true

module Books
  class DeletionService < ::ServiceBase
    def initialize(creator, book_id)
      super
      @creator = creator
      @book_id = book_id
    end

    def call
      if creator.nil?
        add_error('creator is required')
        return
      end

      @book = creator.books.find(book_id)

      ActiveRecord::Base.transaction do
        handle_author_associations

        add_errors(book.errors) unless book.destroy
      end

      book
    rescue ActiveRecord::RecordNotFound => e
      add_error(e)
    end

    private

    attr_reader :creator, :book_id, :book

    def handle_author_associations
      book.authors.clear
    end
  end
end
