# frozen_string_literal: true

class AgentImportBookThreadRun < AgentImportThreadRun
  has_one :agent_import_workflow_item, inverse_of: :book_thread_run, foreign_key: :book_thread_run_id

  def messages
    agent_import_messages.order(created_at: :asc).all.map do |message|
      {
        role: message.role,
        content: message.content
      }
    end
  end
end
