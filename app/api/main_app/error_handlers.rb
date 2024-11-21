# frozen_string_literal: true

module MainApp
  module ErrorHandlers
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordNotFound do |_|
        error!(GoogleJsonResponse.render_error("Record not found"), 404)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        error!(GoogleJsonResponse.render_error(e.record.errors.full_messages.join(', ')), 422)
      end
    end
  end
end
