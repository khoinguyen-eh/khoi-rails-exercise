# frozen_string_literal: true

module Users
  class CreationService < ::ServiceBase
    def initialize(user_params)
      super
      @user_params = user_params
    end

    def call
      user = User.new(user_params)
      add_error(user.errors) unless user.save

      user
    end

    private

    attr_reader :user_params
  end
end
