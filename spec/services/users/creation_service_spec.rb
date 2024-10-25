# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::CreationService, type: :service do
  let(:user_params) do
    {
      email: 'user@example.com',
      password: 'secretpassword',
      first_name: 'John',
      last_name: 'Doe',
      gender: true,
      date_of_birth: Time.zone.now
    }
  end

  describe 'successful user creation' do
    it 'creates a user with valid params' do
      service = described_class.new(user_params)
      user = service.call

      expect(service).to be_success
      expect(user).to be_persisted
      expect(user.email).to eq('user@example.com')
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
    end
  end

  describe 'user creation with errors' do
    it 'does not create a user without an email' do
      service = described_class.new(user_params.except(:email))
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end

    it 'does not create a user with an invalid email' do
      user_params[:email] = 'invalid_email'
      service = described_class.new(user_params)
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end

    it 'does not create a user without a password' do
      service = described_class.new(user_params.except(:password))
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end

    it 'does not create a user with a short password' do
      user_params[:password] = 'short'
      service = described_class.new(user_params)
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end

    it 'does not create a user without a date of birth' do
      service = described_class.new(user_params.except(:date_of_birth))
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end

    it 'does not create a user without a first_name' do
      service = described_class.new(user_params.except(:first_name))
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end

    it 'does not create a user without a last_name' do
      service = described_class.new(user_params.except(:last_name))
      user = service.call

      expect(service).not_to be_success
      expect(user).not_to be_persisted
    end
  end
end
