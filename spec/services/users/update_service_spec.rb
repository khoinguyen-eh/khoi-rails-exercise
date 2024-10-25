# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::UpdateService, type: :service do
  let(:user) { create(:user, password: 'old_password') }
  let(:valid_params) { { email: 'new_email@example.com', password: 'new_password', current_password: 'old_password' } }
  let(:invalid_password_params) { { password: 'new_password', current_password: 'wrong_password' } }
  let(:missing_password_params) { { password: 'new_password' } }
  let(:token_service) { instance_double(Users::TokenService, call: 'new_token', success?: true, errors: []) }

  before do
    allow(Users::TokenService).to receive(:new).and_return(token_service)
  end

  describe 'successful user update' do
    it 'updates user with valid params' do
      service = described_class.new(user, valid_params)
      new_token = service.call

      expect(service).to be_success
      expect(user.reload.email).to eq('new_email@example.com')
      expect(new_token).to eq('new_token')
    end

    it 'clears and generates new token if password is updated' do
      service = described_class.new(user, valid_params)
      new_token = service.call

      expect(token_service).to have_received(:call).with(:clear)
      expect(token_service).to have_received(:call).with(:new)
      expect(new_token).to eq('new_token')
    end
  end

  describe 'user update with errors' do
    it 'does not update user with incorrect current password' do
      service = described_class.new(user, invalid_password_params)
      new_token = service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('Current password is incorrect'))
      expect(new_token).to be_nil
    end

    it 'does not update user if password and current password are not both present or both blank' do
      service = described_class.new(user, missing_password_params)
      new_token = service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('Password and current password must be both present or both blank'))
      expect(new_token).to be_nil
    end

    it 'adds errors if user save fails' do
      allow(user).to receive(:save).and_return(false)
      allow(user).to receive(:errors).and_return([StandardError.new('Save failed')])

      service = described_class.new(user, valid_params)
      new_token = service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('Save failed'))
      expect(new_token).to be_nil
    end

    it 'adds token service errors if token generation fails' do
      allow(token_service).to receive(:success?).and_return(false)
      allow(token_service).to receive(:errors).and_return([StandardError.new('Token generation failed')])

      service = described_class.new(user, valid_params)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('Token generation failed'))
    end
  end
end
