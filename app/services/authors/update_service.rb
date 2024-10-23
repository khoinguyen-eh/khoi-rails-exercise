# frozen_string_literal: true

module Authors
  class UpdateService < ::ServiceBase
    def initialize(author, update_params)
      super
      @author = author
      @update_params = update_params
    end

    def call
      author.assign_attributes(update_params)
      add_errors(author.errors) unless author.save

      author
    rescue ActiveRecord::RecordNotFound => e
      add_error(e.message)
    end

    private

    attr_reader :author, :update_params
  end
end
