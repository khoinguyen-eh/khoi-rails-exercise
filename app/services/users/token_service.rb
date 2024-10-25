# frozen_string_literal: true

module Users
  class TokenService < ::ServiceBase
    def initialize(user_id, token = nil)
      super
      @user_id = user_id
      @token = token
    end

    def call(type)
      case type
      when :new
        new
      when :remove
        remove
      when :clear
        clear
      else
        add_error('Invalid type')
      end
    rescue Redis::BaseError => e
      add_error(e)
    end

    private

    attr_reader :user_id, :token

    def new
      new_token = SecureRandom.hex(16)

      REDIS_CLIENT.with do |conn|
        conn.set("user:token:#{new_token}", user_id)
        conn.sadd("user:#{user_id}:tokens", new_token)
      end

      new_token
    end

    def remove
      if token.blank?
        add_error('Token must be present')
        return
      end

      REDIS_CLIENT.with do |conn|
        conn.del("user:token:#{token}")
        conn.srem("user:#{user_id}:tokens", token)
      end
    end

    def clear
      REDIS_CLIENT.with do |conn|
        old_tokens = conn.smembers("user:#{user_id}:tokens")
        old_tokens.each do |old_token|
          conn.del("user:token:#{old_token}")
        end

        conn.del("user:#{user_id}:tokens")
      end
    end
  end
end
