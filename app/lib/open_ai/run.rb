# frozen_string_literal: true

module OpenAi
  class Run < Base
    STATUSES = [
      QUEUED = "queued",
      IN_PROGRESS = "in_progress",
      REQUIRES_ACTION = "requires_action",
      CANCELLING = "cancelling",
      CANCELLED = "cancelled",
      FAILED = "failed",
      COMPLETED = "completed",
      INCOMPLETE = "incomplete",
      EXPIRED = "expired"
    ].freeze

    class << self
      def run_assistant(assistant_id, thread_params, run_params = {}, version = DEFAULT_ASSISTANT_VERSION)
        create_thread_and_run(assistant_id, thread_params, run_params, version)
      end

      def assistant_run_completed?(assistant_run)
        assistant_finished_status?(assistant_run)
      end

      def retrieve_assistant_run(thread_id:, run_id:, version: DEFAULT_ASSISTANT_VERSION)
        base_client(version).retrieve(thread_id: thread_id, id: run_id)
      end

      private

      def assistant_finished_status?(assistant_run)
        assistant_status = assistant_run&.dig('status')
        [CANCELLED, FAILED, COMPLETED, INCOMPLETE, EXPIRED].include?(assistant_status)
      end

      def create_thread_and_run(assistant_id, thread_params, run_params = {}, version = DEFAULT_ASSISTANT_VERSION)
        parameters = run_params.merge({ assistant_id: assistant_id, thread: thread_params })
        base_client(version).create_thread_and_run(parameters: parameters)
      end

      def base_client(version = DEFAULT_ASSISTANT_VERSION)
        OpenAI::Runs.new(client: client, version: version)
      end
    end
  end
end
