# frozen_string_literal: true

module Authors
  class CreationService < ::ServiceBase
    def initialize(author_params)
      super
      @author_params = author_params
    end

    def call
      author = Author.new(author_params)
      add_errors(author.errors) unless author.save

      author
    rescue ActiveRecord::RecordNotFound => e
      add_error(e.message)
    end

    private

    attr_reader :author_params
  end
end
