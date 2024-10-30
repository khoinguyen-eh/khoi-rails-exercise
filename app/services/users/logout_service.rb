# frozen_string_literal: true

module Users
  class LogoutService < ::ServiceBase
    def initialize(user_id:, token:)
      super
      @user_id = user_id
      @token = token
      @token_service = Users::TokenService.new(user_id, token)
    end

    def call
      token_service.call :remove
      add_errors(token_service.errors) unless token_service.success?
    end

    private

    attr_reader :user_id, :token, :token_service
  end
end
