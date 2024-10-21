class CreateAuthors < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:authors)

    create_table :authors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :pen_name
      t.string :bio
      t.boolean :is_verified, default: false

      t.timestamps
    end
  end

  def down
    return unless table_exists?(:authors)

    drop_table :authors
  end
end
