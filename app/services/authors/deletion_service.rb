# frozen_string_literal: true

module Authors
  class DeletionService < ::ServiceBase
    def initialize(creator, author_id)
      super
      @creator = creator
      @author_id = author_id
    end

    def call
      if creator.nil?
        add_error('creator is required')
        return
      end

      @author = creator.authors.find(author_id)

      ActiveRecord::Base.transaction do
        handle_author_associations

        add_errors(author.errors) unless author.destroy

        raise ActiveRecord::Rollback unless success?
      end

      author
    rescue ActiveRecord::RecordNotFound => e
      add_error(e)
    end

    private

    attr_reader :author_id, :creator, :author

    def handle_author_associations
      author.books.clear
    end
  end
end
