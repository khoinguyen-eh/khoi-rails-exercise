# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::LogoutService, type: :service do
  let(:user_id) { 1 }
  let(:token) { 'valid_token' }
  let(:service) { described_class.new(user_id: user_id, token: token) }
  let(:token_service) { instance_double(Users::TokenService, call: nil, success?: true, errors: []) }

  before do
    allow(Users::TokenService).to receive(:new).and_return(token_service)
  end

  describe 'successful logout' do
    it 'calls the token service to remove the token' do
      service.call
      expect(token_service).to have_received(:call).with(:remove)
    end

    it 'does not add errors if token service is successful' do
      service.call
      expect(service.errors).to be_empty
    end
  end

  describe 'logout with token service errors' do
    before do
      allow(token_service).to receive(:success?).and_return(false)
      allow(token_service).to receive(:errors).and_return(['Token removal failed'])
    end

    it 'adds errors if token service fails' do
      service.call
      expect(service.errors).to include('Token removal failed')
    end
  end
end
