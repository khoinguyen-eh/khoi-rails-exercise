# frozen_string_literal: true

module MainApp
  module V1
    class API < ApplicationAPI
      version 'v1', using: :path

      include Grape::Extensions::Hashie::Mash::ParamBuilder
      include MainApp::ErrorHandlers

      format :json
      formatter :json, Grape::Formatter::ActiveModelSerializers

      mount MainApp::V1::Authors

      route :any, '*path' do
        error!(GoogleJsonResponse.render_error("Could not find endpoint"), 404)
      end
    end
  end
end
