# frozen_string_literal: true

class AgentImportAuthorThreadRun < AgentImportThreadRun
  has_one :agent_import_workflow_item, inverse_of: :author_thread_run, foreign_key: :author_thread_run_id

  def messages
    cur_messages = agent_import_messages.order(created_at: :asc).all.map do |message|
      {
        role: message.role,
        content: message.content
      }
    end

    agent_import_workflow_item.book_thread_run.messages + cur_messages
  end
end
