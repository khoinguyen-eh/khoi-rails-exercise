# frozen_string_literal: true

module Authors
  class CreationService < ::ServiceBase
    def initialize(creator, author_params)
      super
      @creator = creator
      @author_params = author_params
    end

    def call
      if creator.nil?
        add_error('creator is required')
        return
      end

      author = creator.authors.create(author_params)
      add_error(author.errors) unless author.persisted?

      author
    rescue ActiveRecord::RecordNotFound => e
      add_error(e)
    end

    private

    attr_reader :author_params, :creator
  end
end
