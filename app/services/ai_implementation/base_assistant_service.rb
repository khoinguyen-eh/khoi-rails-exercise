# frozen_string_literal: true

module AiImplementation
  class AssistantUnstableError < StandardError; end

  class AssistantTimeoutError < StandardError; end

  class ExceedAssistantRetriedError < StandardError; end

  class AssistantRunError < StandardError; end

  class AssistantNotCompletedError < StandardError; end

  class RetriableError < StandardError; end

  MAX_RETRY_RELIABLE_ERROR = 3
  ASSISTANT_POLLING_DURATION = (ENV['ASSISTANT_POLLING_DURATION'] || 2).to_i.seconds
  ASSISTANT_SLEEP_DURATION = (ENV['ASSISTANT_SLEEP_DURATION'] || 1).to_i.seconds

  class BaseAssistantService < ::ServiceBase
    def initialize(params)
      super
      @params = params
      @workflow_item_id = params['workflow_item_id']
      @custom_message_params = params['custom_message_params'] || {}
      @retry_counter = params["retry_counter"] || 0
      @thread_id = params["thread_id"]
      @run_id = params["run_id"]
    end

    def call
      return self unless assistant_runnable?

      if assistant_run_started?
        poll_assistant_run
        return self
      end

      execute_assistant_run
      mark_current_assistant_started!
      schedule_next_poll

      workflow.mark_processing! if workflow.may_mark_processing?

      self
    rescue AssistantUnstableError, AssistantTimeoutError => e
      add_error(e)
      self
    end

    private

    def current_beta_assistant_version
      OpenAi::DEFAULT_ASSISTANT_VERSION
    end

    def assistant_run_started?
      @thread_id.present? && @run_id.present?
    end

    def assistant_id
      raise NotImplementedError
    end

    def build_assistant_user_messages
      raise NotImplementedError
    end

    def assistant_runnable?
      if @workflow_item_id.blank?
        add_error('Workflow item cannot be blank.')
        return false
      end

      if assistant_id.blank?
        add_error('Assistant cannot be blank.')
        return false
      end

      true
    end

    def execute_assistant_run
      build_assistant_user_messages
      Rails.logger.info "#{self.class.name} call API assistant"
      @assistant = OpenAi::Run.run_assistant(assistant_id, @assistant_user_messages, {}, current_beta_assistant_version)
      @params.merge!({ "thread_id" => @assistant["thread_id"], "run_id" => @assistant["id"] })
    rescue *OpenAi::RETRYABLE_ERRORS => e
      raise AssistantTimeoutError, e.message
    end

    def poll_assistant_run
      @assistant_run = OpenAi::Run.retrieve_assistant_run(thread_id: @thread_id, run_id: @run_id,
                                                          version: current_beta_assistant_version)
      update_assistant_thread_run_status!

      run_completed = OpenAi::Run.assistant_run_completed?(@assistant_run)
      if run_completed
        continue_next_step(thread_id: @thread_id)
      else
        schedule_next_poll
      end
    rescue *OpenAi::RETRYABLE_ERRORS => e
      raise AssistantTimeoutError, e.message
    end

    def thread_run
      @thread_run ||= AgentImportThreadRun.find_by(assistant_run_id: @run_id, assistant_thread_id: @thread_id)
    end

    def update_assistant_thread_run_status!
      raise NotImplementedError
    end

    def mark_current_assistant_started!
      raise NotImplementedError
    end

    def mark_current_assistant_run_completed!
      raise NotImplementedError
    end

    def schedule_next_poll
      raise NotImplementedError
    end

    def workflow
      @workflow ||= workflow_item.agent_import_workflow
    end

    def workflow_item
      @workflow_item ||= AgentImportWorkflowItem.find_by!(id: @workflow_item_id)
    end

    def user
      @user ||= workflow_item.agent_import_workflow.author
    end

    def continue_next_step(thread_id:)
      retrieve_assistant_response(thread_id: thread_id)
      mark_current_assistant_run_completed!
      execute_next_assistant_run
    rescue JSON::ParserError, Faraday::ParsingError
      Rails.logger.info "Assistant #{self.class.name} response invalid JSON format"
      unstable_error_messages = "Assistant #{self.class.name} response invalid JSON format"
      raise AssistantUnstableError, unstable_error_messages
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      raise AssistantUnstableError, e.message
    end

    def retrieve_assistant_response(thread_id:)
      @assistant_response = OpenAi::Message.get_list_thread_messages(thread_id: thread_id,
                                                                     version: current_beta_assistant_version)
    rescue *OpenAi::RETRYABLE_ERRORS => e
      raise AssistantTimeoutError, e.message
    end

    def execute_next_assistant_run
      raise NotImplementedError
    end
  end
end
