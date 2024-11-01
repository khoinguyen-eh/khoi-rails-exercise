class CreateAgentImportWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_import_workflows, id: :uuid do |t|
      t.bigint :author_id, null: false, index: true
      t.string :status, null: false
      t.string :book_prompt, null: false
      t.string :author_prompt, null: false

      t.timestamps
    end
  end
end
