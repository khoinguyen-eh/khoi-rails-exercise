# frozen_string_literal: true

module OpenAi
  class RateLimitError < Faraday::ClientError
  end

  module Middleware
    class RaiseRateLimitErrors < Faraday::Response::RaiseError
      def on_complete(env)
        case env[:status]
        when 429
          raise RateLimitError, response_values(env)
        end
      end
    end
  end
end
