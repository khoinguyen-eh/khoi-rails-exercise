class CreateBooks < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:books)

    create_table :books do |t|
      t.string :isbn, null: false
      t.string :name
      t.string :description, default: ''
      t.decimal :rating, precision: 3, scale: 2, default: 0.0
      t.datetime :published_at

      t.timestamps
    end

    add_index :books, :isbn, unique: true
  end

  def down
    return unless table_exists?(:books)

    drop_table :books
  end
end
