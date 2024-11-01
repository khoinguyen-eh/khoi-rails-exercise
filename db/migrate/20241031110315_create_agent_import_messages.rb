class CreateAgentImportMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_import_messages, id: :uuid do |t|
      t.uuid :agent_import_thread_run_id, null: false, index: true
      t.string :role, null: false
      t.text :content

      t.timestamps
    end
  end
end
