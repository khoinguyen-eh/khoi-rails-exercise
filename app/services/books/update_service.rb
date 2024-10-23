# frozen_string_literal: true

module Books
  class UpdateService < ::ServiceBase
    def initialize(book, update_params)
      super
      @book = book
      @update_params = update_params
    end

    def call
      book.assign_attributes(update_params)
      add_errors(book.errors) unless book.save

      book
    rescue ActiveRecord::RecordNotFound => e
      add_error(e.message)
    end

    private

    attr_reader :book, :update_params
  end
end
