# frozen_string_literal: true

module Users
  class UpdateService < ::ServiceBase
    def initialize(user, update_params)
      super
      @user = user
      @update_params = update_params
      @token_service = Users::TokenService.new(user.id)
    end

    def call
      unless update_params[:password].present? ^ update_params[:current_password].blank?
        add_error('Password and current password must be both present or both blank')
        return
      end

      if update_params[:password].present? && !user.authenticate(update_params[:current_password])
        add_error('Current password is incorrect')
        return
      end

      user.assign_attributes(update_params.except(:current_password))
      add_errors(user.errors) unless user.save

      new_token = nil

      if success? && update_params[:password].present?
        token_service.call :clear
        new_token = token_service.call :new

        add_errors(token_service.errors) unless token_service.success?
      end

      new_token
    end

    private

    attr_reader :user, :update_params, :token_service
  end
end
