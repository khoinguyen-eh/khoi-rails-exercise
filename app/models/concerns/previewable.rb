# frozen_string_literal: true

module Previewable
  extend ActiveSupport::Concern

  included do
    scope :preview, lambda { |lim: 5|
      limit([lim, 0].max)
    }
  end
end
