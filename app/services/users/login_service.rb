# frozen_string_literal: true

module Users
  class LoginService < ::ServiceBase
    def initialize(email:, password:)
      super
      @email = email
      @password = password
    end

    def call
      user = User.find_by(email: email)
      unless user&.authenticate(password)
        add_error('Invalid email or password')
        return
      end

      token_service = Users::TokenService.new(user.id)
      token = token_service.call :new

      add_errors(token_service.errors) unless token_service.success?

      token
    end

    private

    attr_reader :email, :password
  end
end
