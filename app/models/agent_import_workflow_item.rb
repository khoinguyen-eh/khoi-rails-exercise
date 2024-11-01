# frozen_string_literal: true

class AgentImportWorkflowItem < ApplicationRecord
  include AASM

  belongs_to :agent_import_workflow, inverse_of: :agent_import_workflow_items
  belongs_to :book_thread_run, class_name: 'AgentImportBookThreadRun', inverse_of: :agent_import_workflow_item,
                               dependent: :destroy, optional: true
  belongs_to :author_thread_run, class_name: 'AgentImportAuthorThreadRun', inverse_of: :agent_import_workflow_item,
                                 dependent: :destroy, optional: true

  STATUSES = [
    INITIAL = :initial,
    BOOK = :book,
    AUTHOR = :author,
    FAILED = :failed,
    SUCCESSFUL = :successful
  ].freeze

  PROCESSING_STATUSES = [
    BOOK,
    AUTHOR
  ].freeze

  scope :not_successful, -> { where.not(status: SUCCESSFUL) }
  scope :successful, -> { where(status: SUCCESSFUL) }
  scope :not_complete, -> { where.not(status: [SUCCESSFUL, FAILED]) }
  scope :failed, -> { where(status: FAILED) }
  scope :initial, -> { where(status: INITIAL) }

  aasm column: :status do
    state INITIAL, initial: true
    state BOOK, AUTHOR, FAILED, SUCCESSFUL

    event :mark_book do
      transitions from: [FAILED, SUCCESSFUL, INITIAL], to: BOOK
    end

    event :mark_author do
      transitions from: BOOK, to: AUTHOR
    end

    event :mark_failed do
      transitions from: [BOOK, AUTHOR], to: FAILED
    end

    event :mark_successful do
      transitions from: AUTHOR, to: SUCCESSFUL
    end
  end
end
