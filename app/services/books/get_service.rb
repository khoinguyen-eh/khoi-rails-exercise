# frozen_string_literal: true

module Books
  class GetService < ::ServiceBase
    def initialize(page = nil, per_page = nil, options = {})
      super
      @page = page
      @per_page = per_page
      @top_rated = options[:top_rated]
    end

    def call
      books = Book.all

      if top_rated
        books = books.where('rating >= ?', top_rated[:min_rating]) if top_rated[:min_rating]
        books = books.order(rating: :desc).limit(top_rated[:limit] || 10)
        @per_page = [top_rated[:limit], per_page].compact.min
      end

      books = books.paginate(page: page, per_page: per_page) if page && per_page

      books
    end

    private

    attr_reader :page, :per_page, :top_rated
  end
end
