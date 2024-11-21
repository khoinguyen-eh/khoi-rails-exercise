# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::DeletionService, type: :service do
  let(:user) { create(:user) }
  let(:token_service) { instance_double(Users::TokenService, call: nil, success?: true, errors: []) }

  before do
    allow(Users::TokenService).to receive(:new).and_return(token_service)
  end

  describe 'successful user deletion' do
    it 'deletes the user and clears tokens' do
      service = described_class.new(user)
      service.call

      expect(service).to be_success
      expect(user).to be_destroyed
      expect(token_service).to have_received(:call).with(:clear)
    end
  end

  describe 'user deletion with errors' do
    it 'does not delete the user if there are associated errors' do
      allow(user).to receive(:destroy).and_return(false)
      allow(user).to receive(:errors).and_return([StandardError.new('Deletion failed')])

      service = described_class.new(user)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include(StandardError.new('Deletion failed'))
    end

    it 'adds token service errors if token clearing fails' do
      allow(token_service).to receive(:success?).and_return(false)
      allow(token_service).to receive(:errors).and_return(['Token clearing failed'])

      service = described_class.new(user)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include('Token clearing failed')
    end
  end
end
