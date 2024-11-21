# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::Users, type: :request do
  let!(:user) { create(:user, password: 'secretpassword') }
  let(:headers) { { 'HTTP_AUTHORIZATION' => 'valid_token' } }
  let(:redis_key) { "user:token:valid_token" }

  before do
    redis_double = instance_double(Redis)
    allow(redis_double).to receive(:get).and_return(nil)
    allow(redis_double).to receive(:get).with(redis_key).and_return(user.id)
    allow(redis_double).to receive(:set)
    allow(redis_double).to receive(:sadd)
    allow(redis_double).to receive(:del)
    allow(redis_double).to receive(:smembers).with("user:#{user.id}:tokens").and_return(['valid_token'])
    allow(redis_double).to receive(:srem)
    allow(REDIS_CLIENT).to receive(:with).and_yield(redis_double)
    allow(REDIS_CLIENT).to receive(:del)
  end

  describe 'POST /api/v1/users/login' do
    let(:params) { { email: user.email, password: user.password } }

    it 'logs in with valid credentials' do
      post '/api/v1/users/login', params: params
      expect(json_response).to have_key('token')
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized with invalid credentials' do
      post '/api/v1/users/login', params: { email: user.email, password: 'wrong_password' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/users/logout' do
    it 'logs out successfully' do
      post '/api/v1/users/logout', headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized if not logged in' do
      post '/api/v1/users/logout'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/users' do
    it 'retrieves all users' do
      get '/api/v1/users'
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['items']).to be_an(Array)
    end
  end

  describe 'GET /api/v1/users/:id' do
    it 'retrieves a specific user' do
      get "/api/v1/users/#{user.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(user.id)
    end
  end

  describe 'POST /api/v1/users' do
    let(:params) {
      {
        email: 'new_user@example.com',
        password: "secretpassword",
        first_name: 'First',
        last_name: 'Last',
        date_of_birth: '2000-01-01',
        gender: true
      }
    }

    it 'creates a new user with valid params' do
      post '/api/v1/users', params: params
      expect(response).to have_http_status(:created)
      expect(json_response['data']['email']).to eq('new_user@example.com')
    end

    it 'returns bad request with invalid params' do
      post '/api/v1/users', params: params.except(:email)
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT /api/v1/users/:id' do
    let(:params) {
      {
        email: 'updated_email@example.com',
        current_password: "secretpassword",
        password: 'new_password',
        first_name: 'Updated',
        last_name: 'User',
        date_of_birth: '2000-01-01',
        gender: true
      }
    }

    it 'updates a user with valid params' do
      put "/api/v1/users/#{user.id}", params: params, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response).to have_key('new_token')
    end

    it 'returns forbidden with invalid current password' do
      put "/api/v1/users/#{user.id}", params: params.merge(current_password: 'wrong_password'), headers: headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns bad request with password but no current password' do
      put "/api/v1/users/#{user.id}", params: params.except(:current_password), headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request with current password but no password' do
      put "/api/v1/users/#{user.id}", params: params.except(:password), headers: headers
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'DELETE /api/v1/users/:id' do
    it 'deletes a user successfully' do
      delete "/api/v1/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns forbidden if user deletion fails' do
      allow_any_instance_of(User).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
      delete "/api/v1/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
