# frozen_string_literal: true

module Authors
  class DeletionService < ::ServiceBase
    def initialize(author)
      super
      @author = author
    end

    def call
      ActiveRecord::Base.transaction do
        handle_author_associations

        add_errors(author.errors) unless author.destroy
      end

      author
    end

    private

    attr_reader :author

    def handle_author_associations
      author.books.clear
    end
  end
end
