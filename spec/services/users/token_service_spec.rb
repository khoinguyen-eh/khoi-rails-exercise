# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::TokenService, type: :service do
  let(:user_id) { 1 }
  let(:token) { 'existing_token' }
  let(:service) { described_class.new(user_id, token) }
  let(:redis_instance) { instance_double(Redis) }

  before do
    allow(REDIS_CLIENT).to receive(:with).and_yield(redis_instance)
    allow(SecureRandom).to receive(:hex).and_return('new_token')
    allow(redis_instance).to receive(:set)
    allow(redis_instance).to receive(:sadd)
    allow(redis_instance).to receive(:smembers).and_return([token])
    allow(redis_instance).to receive(:del)
    allow(redis_instance).to receive(:srem)
  end

  describe 'generating a new token' do
    it 'returns a new token' do
      allow(SecureRandom).to receive(:hex).and_return('new_token')
      new_token = service.call(:new)

      expect(new_token).to eq('new_token')
    end

    it 'adds the new token to Redis' do
      service.call(:new)

      expect(redis_instance).to have_received(:set).with('user:token:new_token', anything)
      expect(redis_instance).to have_received(:sadd).with("user:#{user_id}:tokens", 'new_token')
    end
  end

  describe 'removing a token' do
    it 'removes the token from Redis' do
      service.call(:remove)

      expect(redis_instance).to have_received(:del).with("user:token:#{token}")
      expect(redis_instance).to have_received(:srem).with("user:#{user_id}:tokens", token)
    end

    it 'returns an error if token is blank' do
      service = described_class.new(user_id, nil)
      service.call(:remove)

      expect(service.errors).to include(StandardError.new('Token must be present'))
    end
  end

  describe 'clearing all tokens' do
    it 'removes all tokens from Redis' do
      service.call(:clear)

      expect(redis_instance).to have_received(:smembers).with("user:#{user_id}:tokens")
      expect(redis_instance).to have_received(:del).with("user:token:#{token}")
    end
  end

  describe 'handling invalid type' do
    it 'returns an error for invalid type' do
      service.call(:invalid)

      expect(service.errors).to include(StandardError.new('Invalid type'))
    end
  end

  describe 'handling Redis errors' do
    it 'returns an error when Redis raises an exception' do
      allow(REDIS_CLIENT).to receive(:with).and_raise(Redis::BaseError.new('Redis error'))

      service.call(:new)

      expect(service.errors).to include(
        an_instance_of(Redis::BaseError).and(having_attributes(message: 'Redis error'))
      )
    end
  end
end
