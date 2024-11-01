# frozen_string_literal: true

module AgentImportWorkflows
  class UpdateService < ::ServiceBase
    def initialize(creator, workflow_id, update_params)
      super
      @creator = creator
      @workflow_id = workflow_id
      @update_params = update_params
    end

    def call
      return self unless creator_valid?

      @workflow = creator.agent_import_workflows.find(workflow_id)

      workflow.assign_attributes(update_params)
      add_errors(workflow.errors) unless workflow.save

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

    attr_reader :update_params, :creator, :workflow_id, :workflow
  end
end
