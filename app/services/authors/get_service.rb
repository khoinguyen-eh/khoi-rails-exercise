# frozen_string_literal: true

module Authors
  class GetService < ::ServiceBase
    def initialize(page = nil, per_page = nil)
      super
      @page = page
      @per_page = per_page
    end

    def call
      authors = Author.all
      authors = authors.paginate(page: page, per_page: per_page) if page && per_page

      authors
    end

    private

    attr_reader :page, :per_page
  end
end
