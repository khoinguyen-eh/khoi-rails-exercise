# frozen_string_literal: true

module Users
  class DeletionService < ::ServiceBase
    def initialize(user)
      super
      @user = user
      @token_service = Users::TokenService.new(user.id)
    end

    def call
      add_error(user.errors) unless user.destroy

      if success?
        token_service.call :clear
        add_errors(token_service.errors) unless token_service.success?
      end
    end

    private

    attr_reader :user, :token_service
  end
end
