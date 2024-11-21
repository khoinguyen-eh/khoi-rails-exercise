class CreateAgentImportWorkflowItems < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_import_workflow_items, id: :uuid do |t|
      t.uuid :agent_import_workflow_id, null: false, index: true
      t.string :status, null: false
      t.uuid :book_thread_run_id, null: true
      t.uuid :author_thread_run_id, null: true
      t.index [:book_thread_run_id], name: :book_thread_run_id, unique: true
      t.index [:author_thread_run_id], name: :author_thread_run_id, unique: true

      t.timestamps
    end
  end
end
