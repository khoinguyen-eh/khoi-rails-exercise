class AddFileIdToBooks < ActiveRecord::Migration[7.0]
  def up
    add_column :books, :file_id, :integer
  end

  def down
    remove_column :books, :file_id
  end
end
