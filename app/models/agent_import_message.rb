# frozen_string_literal: true

class AgentImportMessage < ApplicationRecord
  belongs_to :agent_import_thread_run, inverse_of: :agent_import_messages
end
