class CreateUsers < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:users)

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.boolean :gender
      t.datetime :date_of_birth

      t.timestamps
    end

    add_index :users, :email, unique: true
  end

  def down
    return unless table_exists?(:users)

    drop_table :users
  end
end
