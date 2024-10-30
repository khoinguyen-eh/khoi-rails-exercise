# frozen_string_literal: true

class MainApp::V1::Users < ApplicationAPI
  use ::MainApp::V1::Middlewares::GetCurrentUserId

  before do
    @current_user_id = env['custom_data.current_user_id']
    @current_user_token = env['custom_data.current_user_token']

    if request.path.match?(/\/api\/v1\/users\/\d+/) && %w[PUT DELETE].include?(request.request_method)
      authenticate_user!
    end
  end

  helpers do
    def authenticate_user!
      if @current_user_id.nil?
        error!('Unauthorized', 401)
      elsif @current_user_id != params[:id].to_i
        error!('Forbidden', 403)
      end
    end

    params :user_content do
      requires :email, type: String
      requires :first_name, type: String
      requires :last_name, type: String
      requires :date_of_birth, type: Date
      requires :gender, type: Boolean
    end

    def find_user
      User.find(params[:id])
    end

    def render_user(author)
      GoogleJsonResponse.render(
        author,
        serializer_klass: MainApp::V1::UserSerializer
      )
    end
  end

  resource :users do
    params do
      requires :email, type: String
      requires :password, type: String
    end

    desc 'Login'
    post :login do
      service = Users::LoginService.new(email: params[:email], password: params[:password])
      token = service.call

      if service.success?
        status 200
        { token: token }
      elsif service.has_error_class?(Redis::BaseError)
        error!(service.errors, 500)
      else
        error!(service.errors, 401)
      end
    end

    desc 'Logout'
    post :logout do
      error!('Unauthorized', 401) if @current_user_id.nil?

      service = Users::LogoutService.new(user_id: @current_user_id, token: @current_user_token)
      service.call

      if service.success?
        status 204
      else
        error!(service.errors, 500)
      end
    end

    desc 'Get all users'
    get do
      users = User.all
      render_user(users)
    end

    route_param :id do
      desc 'Get a user'
      get do
        user = find_user
        render_user(user)
      end
    end

    params do
      use :user_content
      requires :password, type: String
    end
    desc 'Create a user'
    post do
      parsed_params = declared(params, include_missing: false)
      service = Users::CreationService.new(parsed_params)
      user = service.call

      if service.success?
        render_user(user)
      else
        error!(service.errors, 422)
      end
    end

    params do
      use :user_content
      optional :password, type: String
      optional :current_password, type: String
      all_or_none_of :password, :current_password
    end
    desc 'Update a user'
    put ':id' do
      user = find_user
      update_params = declared(params, include_missing: false)

      service = Users::UpdateService.new(user, update_params)
      new_token = service.call

      if service.success?
        { new_token: new_token }
      elsif service.has_error_class?(Redis::BaseError)
        error!(service.errors, 500)
      else
        error!(service.errors, 403)
      end
    end

    desc 'Delete a user'
    delete ':id' do
      user = find_user

      service = Users::DeletionService.new(user)
      service.call

      if service.success?
        status 204
      elsif service.has_error_class?(Redis::BaseError)
        error!(service.errors, 500)
      else
        error!(service.errors, 403)
      end
    end
  end
end
