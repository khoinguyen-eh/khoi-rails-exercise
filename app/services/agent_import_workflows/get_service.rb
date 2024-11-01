# frozen_string_literal: true

module AgentImportWorkflows
  class GetService < ::ServiceBase
    def initialize(page = nil, per_page = nil)
      super
      @page = page
      @per_page = per_page
    end

    def call
      @workflows = AgentImportWorkflow.all
      @workflows = workflows.paginate(page: page, per_page: per_page) if page && per_page

      self
    end

    def data
      workflows
    end

    private

    attr_reader :page, :per_page, :workflows
  end
end
