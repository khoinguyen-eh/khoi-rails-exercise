# frozen_string_literal: true

module AiImplementation
  class HandleAssistantError < ::ServiceBase
    # @param [String] workflow_item_id
    # @param [StandardError] error
    def initialize(workflow_item_id, error)
      super
      @workflow_item_id = workflow_item_id
      @error = error
    end

    def call
      Rails.logger.warn "Error when handle assistant error for workflow item ##{@workflow_item_id}: #{@error}"
      handle_assistant_error
    rescue StandardError => e
      Rails.logger.error "Error when handle assistant error for workflow item ##{@workflow_item_id}: #{e.message}, original error: #{@error.message}"
    end

    private

    def workflow_item
      @workflow_item ||= AgentImportWorkflowItem.find(@workflow_item_id)
    end

    def workflow
      workflow_item.agent_import_workflow
    end

    def handle_assistant_error
      ActiveRecord::Base.transaction do
        workflow.lock!
        workflow_item.mark_failed!
        workflow.mark_successful! if workflow.should_be_successful?
        workflow.mark_failed! if workflow.should_be_failed?
      end
    end
  end
end
