# frozen_string_literal: true

module AgentImportWorkflows
  class DeletionService < ::ServiceBase
    def initialize(creator, workflow_id)
      super
      @creator = creator
      @workflow_id = workflow_id
    end

    def call
      return self unless creator_valid?

      workflow = creator.agent_import_workflows.find(workflow_id)
      workflow.destroy!

      self
    rescue ActiveRecord::ActiveRecordError => e
      add_error(e)
    end

    private

    def creator_valid?
      return true if creator

      add_error('creator is required')
      false
    end

    attr_reader :workflow_id, :creator
  end
end
