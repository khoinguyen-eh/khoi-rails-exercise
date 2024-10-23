# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::LoginService, type: :service do
  let!(:user) { create(:user, email: 'user@example.com', password: 'password') }
  let(:valid_params) { { email: 'user@example.com', password: 'password' } }
  let(:invalid_email_params) { { email: 'invalid@example.com', password: 'password' } }
  let(:invalid_password_params) { { email: 'user@example.com', password: 'wrong_password' } }
  let(:token_service) { object_double(Users::TokenService.new(user.id)) }

  describe 'successful login' do
    it 'returns a token with valid credentials' do
      service = described_class.new(valid_params)
      token = service.call

      expect(service).to be_success
      expect(token).not_to be_nil
    end
  end

  describe 'login with invalid credentials' do
    it 'returns an error with invalid email' do
      service = described_class.new(invalid_email_params)
      token = service.call

      expect(service).not_to be_success
      expect(token).to be_nil
      expect(service.errors).to include(StandardError.new('Invalid email or password'))
    end

    it 'returns an error with invalid password' do
      service = described_class.new(invalid_password_params)
      token = service.call

      expect(service).not_to be_success
      expect(token).to be_nil
      expect(service.errors).to include(StandardError.new('Invalid email or password'))
    end
  end

  describe 'login with token service errors' do
    before do
      allow(Users::TokenService).to receive(:new).and_return(token_service)
      allow(token_service).to receive(:call).and_return(nil)
      allow(token_service).to receive(:success?).and_return(false)
      allow(token_service).to receive(:errors).and_return(['Token generation failed'])
    end

    it 'returns an error when token service fails' do
      service = described_class.new(valid_params)
      token = service.call

      expect(service).not_to be_success
      expect(token).to be_nil
      expect(service.errors).to include('Token generation failed')
    end
  end
end
