# frozen_string_literal: true

class AiImplementation::AgentImportAssistantWorker
  include Sidekiq::Worker

  sidekiq_options queue: :system_tasks, retry: 3, backtrace: true

  def perform(workflow_item_id,
              retry_counter = 0,
              thread_id = nil,
              run_id = nil)
    return if workflow_item_id.blank?

    workflow_item = AgentImportWorkflowItem.find_by(id: workflow_item_id)
    if workflow_item.blank?
      Sidekiq.logger.error "Workflow item not found with id: #{workflow_item_id}"
      return
    end

    service_assistant_params = {
      "workflow_item_id" => workflow_item_id,
      "retry_counter" => retry_counter,
      "thread_id" => thread_id,
      "run_id" => run_id
    }

    service = service_assistant_instance(workflow_item, service_assistant_params)
    return if service.blank?

    Sidekiq.logger.info "Workflow is running at Assistant #{service.class} with current #{retry_counter} time"
    Sidekiq.logger.info "Worker is running polling to wait for assistant" if thread_id.present?

    service.call
    unless service.success?
      if service.has_error_class?(AiImplementation::AssistantUnstableError)
        if retry_counter >= AiImplementation::MAX_RETRY_RELIABLE_ERROR
          error_message = "Assistant has reached max #{AiImplementation::MAX_RETRY_RELIABLE_ERROR} times"
          Sidekiq.logger.error error_message
          raise AiImplementation::ExceedAssistantRetriedError, error_message
        end
        Sidekiq.logger.error "Retry current assistant: #{service.errors.first.message} with new thread and run id"
        return self.class.perform_async(workflow_item_id, retry_counter + 1)
      elsif service.has_error_class?(AiImplementation::AssistantTimeoutError)
        Sidekiq.logger.error "SidekiqSafeRetry with assistant timeout: #{service.errors.first.message}"
        raise AiImplementation::SidekiqSafeRetry, service.errors.first
      end

      Sidekiq.logger.error "Assistant error: #{service.errors.first.message}"
      AiImplementation::HandleAssistantError.call(workflow_item_id, service.errors.first)
    end
  rescue AiImplementation::SidekiqSafeRetry => e
    Sidekiq.logger.error "SidekiqSafeRetry: #{e.message}"
    raise e
  rescue StandardError => e
    AiImplementation::HandleAssistantError.call(workflow_item_id, e)
  end

  def service_assistant_instance(workflow_item, service_params)
    case true # rubocop:disable Lint/LiteralAsCondition
    when workflow_item.book?
      service_instance = AiImplementation::BookAssistantService.new(**service_params)
    when workflow_item.author?
      service_instance = AiImplementation::AuthorAssistantService.new(**service_params)
    else
      raise NotImplementedError
    end

    service_instance
  end
end
