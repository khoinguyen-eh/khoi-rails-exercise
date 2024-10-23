# frozen_string_literal: true

module Books
  class DeletionService < ::ServiceBase
    def initialize(book)
      super
      @book = book
    end

    def call
      ActiveRecord::Base.transaction do
        handle_author_associations

        add_errors(book.errors) unless book.destroy
      end

      book
    end

    private

    attr_reader :book

    def handle_author_associations
      book.authors.clear
    end
  end
end
