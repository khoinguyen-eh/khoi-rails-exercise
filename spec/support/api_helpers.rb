# frozen_string_literal: true

module ApiHelpers
  def json_response
    JSON.parse(response.body).with_indifferent_access
  end
end
