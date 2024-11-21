# frozen_string_literal: true

class AiImplementation::SidekiqSafeRetry < StandardError
  attr_reader :real_error

  def initialize(real_error, ignore_after_retry: false)
    raise ArgumentError, 'Must provide an exception of or inherited from StandardError' unless real_error.is_a?(StandardError)

    super(real_error.message)
    @real_error = real_error
    @ignore_after_retry = ignore_after_retry
  end

  def ignore_after_retry?
    @ignore_after_retry
  end
end
