# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::ErrorHandlers, type: :request do
  before do
    dummy = Class.new(ApplicationAPI) do
      include MainApp::ErrorHandlers

      get :index do
        raise ActiveRecord::RecordNotFound
      end

      post :create do
        model = User.new
        model.save!
      end
    end

    Rails.application.routes.draw do
      mount dummy => '/'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  describe 'handling ActiveRecord::RecordNotFound' do
    it 'returns a 404 status with a record not found message' do
      get '/index'
      expect(response.status).to eq(404)
      expect(response.body).to include('Record not found')
    end
  end

  describe 'handling ActiveRecord::RecordInvalid' do
    it 'returns a 422 status with validation error messages' do
      post '/create'
      expect(response.status).to eq(422)
      expect(response.body).to include("Email can't be blank")
    end
  end
end
