# frozen_string_literal: true

module OpenAi
  # TODO: Add OpenAi::RateLimitError to RETRYABLE_ERRORS
  RETRYABLE_ERRORS = [Errno::ETIMEDOUT, Net::ReadTimeout, Net::OpenTimeout,
                      Faraday::ServerError, Faraday::ConnectionFailed, Faraday::ConflictError].freeze
  DEFAULT_ASSISTANT_VERSION = 'v2'

  TOOLS = [
    CODE_INTERPRETER = 'code_interpreter',
    FILE_SEARCH = 'file_search',
    RETRIEVAL = 'retrieval'
  ].freeze

  MODELS = [
    GPT_3_5_TURBO = 'gpt-3.5-turbo'
  ].freeze

  Faraday::Response.register_middleware(raise_rate_limit_errors: OpenAi::Middleware::RaiseRateLimitErrors)
end
