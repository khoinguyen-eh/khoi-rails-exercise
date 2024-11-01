class CreateAgentImportThreadRuns < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:agent_import_thread_runs)

    create_table :agent_import_thread_runs, id: :uuid do |t|
      t.string :status, null: false
      t.string :assistant_type, null: false
      t.string :assistant_run_id, null: false
      t.string :assistant_thread_id, null: false
      t.bigint :object_id
      t.index %i[assistant_thread_id assistant_run_id], name: :index_thread_id_and_run_id, unique: true

      t.timestamps
    end
  end

  def down
    drop_table :agent_import_thread_runs if table_exists?(:agent_import_thread_runs)
  end
end
