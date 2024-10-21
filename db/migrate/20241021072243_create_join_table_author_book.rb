class CreateJoinTableAuthorBook < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:authors_books)

    create_join_table :authors, :books do |t|
      t.index %i[author_id book_id], unique: true
    end
  end

  def down
    return unless table_exists?(:authors_books)

    drop_table :authors_books
  end
end
