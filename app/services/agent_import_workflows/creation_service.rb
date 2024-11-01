# frozen_string_literal: true

module AgentImportWorkflows
  class CreationService < ::ServiceBase
    def initialize(creator, workflow_params)
      super
      @creator = creator
      @workflow_params = workflow_params
    end

    def call
      return self unless creator_valid?

      @workflow = creator.agent_import_workflows.create(workflow_params)
      add_error(workflow.errors) unless workflow.persisted?

      if success?
        workflow_item = workflow.agent_import_workflow_items.create(status: 'book')
        AiImplementation::AgentImportAssistantWorker.perform_async(workflow_item.id)
      end

      self
    rescue ActiveRecord::ActiveRecordError => e
      add_error(e)
    end

    def data
      workflow
    end

    private

    def creator_valid?
      return true if creator

      add_error('creator is required')
      false
    end

    attr_reader :workflow_params, :creator, :workflow
  end
end
