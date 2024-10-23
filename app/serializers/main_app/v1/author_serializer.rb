# frozen_string_literal: true

class MainApp::V1::AuthorSerializer < ActiveModel::Serializer
  attributes :id, :pen_name, :bio, :is_verified

  has_many :books, if: :include_books? do
    preview = scope[:include_books]

    case preview
    when 'id_only'
      object.books.preview.map(&:id)
    when 'id_and_name'
      object.books.preview.map { |book| { id: book.id, name: book.name } }
    else
      object.books.preview.map { |book|
        MainApp::V1::BookSerializer.new(book).as_json
      }
    end
  end

  belongs_to :user, if: :include_user?

  def user
    MainApp::V1::UserSerializer.new(object.user).as_json
  end

  def include_books?
    scope && scope[:include_books]
  end

  def include_user?
    scope && scope[:include_user]
  end
end
