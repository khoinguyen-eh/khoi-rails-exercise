# frozen_string_literal: true

module Authors
  class UpdateService < ::ServiceBase
    def initialize(creator, author_id, update_params)
      super
      @creator = creator
      @author_id = author_id
      @update_params = update_params
    end

    def call
      if creator.nil?
        add_error('creator is required')
        return
      end

      author = creator.authors.find(author_id)

      author.assign_attributes(update_params)
      add_errors(author.errors) unless author.save

      author
    rescue ActiveRecord::RecordNotFound => e
      add_error(e)
    end

    private

    attr_reader :update_params, :creator, :author_id
  end
end
