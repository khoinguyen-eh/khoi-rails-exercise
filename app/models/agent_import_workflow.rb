# frozen_string_literal: true

class AgentImportWorkflow < ApplicationRecord
  include Paginatable
  include AASM

  has_many :agent_import_workflow_items, inverse_of: :agent_import_workflow
  belongs_to :author, class_name: 'User', inverse_of: :agent_import_workflows

  STATUSES = [
    INITIAL = :initial,
    PROCESSING = :processing,
    FAILED = :failed,
    SUCCESSFUL = :successful
  ].freeze

  aasm column: :status do
    state INITIAL, initial: true
    state PROCESSING, FAILED, SUCCESSFUL

    event :mark_processing do
      transitions from: [INITIAL, FAILED, SUCCESSFUL], to: PROCESSING
    end

    event :mark_failed do
      transitions from: [SUCCESSFUL, PROCESSING], to: FAILED
    end

    event :mark_successful do
      transitions from: PROCESSING, to: SUCCESSFUL
    end
  end

  def should_be_successful?
    items_count = agent_import_workflow_items.count
    items_count.positive? &&
      agent_import_workflow_items.not_complete.count.zero? &&
      agent_import_workflow_items.successful.count.positive?
  end

  def should_be_failed?
    items_count = agent_import_workflow_items.count
    items_failed_count = agent_import_workflow_items.failed.count
    items_count.positive? && items_failed_count.positive? && items_failed_count == items_count
  end
end
