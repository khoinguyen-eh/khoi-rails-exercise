# frozen_string_literal: true

class AgentImportThreadRun < ApplicationRecord
  self.inheritance_column = :assistant_type

  RUN_STATUSES = [
    QUEUED = 'queued',
    IN_PROGRESS = 'in_progress',
    REQUIRES_ACTION = 'requires_action',
    CANCELLING = 'cancelling',
    CANCELLED = 'cancelled',
    FAILED = 'failed',
    COMPLETED = 'completed',
    EXPIRED = 'expired'
  ].freeze

  validates :status, presence: true, inclusion: { in: RUN_STATUSES }
  validates :assistant_type, presence: true

  has_many :agent_import_messages, inverse_of: :agent_import_thread_run, dependent: :destroy
end
