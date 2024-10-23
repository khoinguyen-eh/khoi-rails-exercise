# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::API, type: :request do
  describe '404 handler' do
    it 'returns the not found error under json format' do
      get '/api/v1/non_existent_endpoint'
      expect(response.status).to eq(404)
      expect(response.body).to include('Could not find endpoint')
    end
  end
end
