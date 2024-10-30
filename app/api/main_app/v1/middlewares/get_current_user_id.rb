# frozen_string_literal: true

module MainApp
  module V1
    module Middlewares
      class GetCurrentUserId < ::Grape::Middleware::Base
        def before
          redis_key = "user:token:#{authorization_header}"
          user_id = REDIS_CLIENT.with do |conn|
            conn.get(redis_key)
          end

          env['custom_data.current_user_id'] = user_id.nil? ? nil : user_id.to_i
          env['custom_data.current_user_token'] = authorization_header
        end

        private

        def authorization_header
          env['HTTP_AUTHORIZATION']
        end
      end
    end
  end
end
