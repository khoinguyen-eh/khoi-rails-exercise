# frozen_string_literal: true

module OpenAi
  class Base
    DEFAULT_REQUEST_TIMEOUT = (ENV['OPENAI_REQUEST_TIMEOUT'] || 120).to_i

    class << self
      def client
        return @client if defined? @client

        @client = OpenAI::Client.new(
          access_token: ENV['OPENAI_API_KEY'],
          request_timeout: DEFAULT_REQUEST_TIMEOUT
        ) do |client|
          client.response :raise_rate_limit_errors
          client.response :json
        end
      end

      private

      def base_client
        client
      end
    end
  end
end
