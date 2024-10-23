# frozen_string_literal: true

module Paginatable
  extend ActiveSupport::Concern

  included do
    scope :paginate, lambda { |page: 1, per_page: 10|
      page = page.to_i < 1 ? 1 : page.to_i
      per_page = per_page.to_i < 1 ? 10 : per_page.to_i
      offset((page - 1) * per_page).limit(per_page)
    }

    scope :paginated_result, lambda { |page: 1, per_page: 10, total_items: nil|
      page = page.to_i < 1 ? 1 : page.to_i
      per_page = per_page.to_i < 1 ? 10 : per_page.to_i
      total_items ||= unscope(:limit, :offset).count
      total_pages = (total_items.to_f / per_page).ceil
      {
        page_index: page,
        item_per_page: per_page,
        total_pages: total_pages,
        total_items: total_items
      }
    }
  end
end
