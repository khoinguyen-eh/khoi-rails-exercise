# frozen_string_literal: true

class MainApp::V1::BookSerializer < ActiveModel::Serializer
  attributes :id, :isbn, :name, :description, :rating, :published_at

  has_many :authors, if: :include_authors? do
    preview = scope[:include_authors]

    case preview
    when 'id_only'
      object.authors.preview.map(&:id)
    when 'id_and_pen_name'
      object.authors.preview.map { |author| { id: author.id, pen_name: author.pen_name } }
    when 'id_and_all_names'
      object.authors.preview.map { |author|
        {
          id: author.id,
          first_name: author.user.first_name,
          last_name: author.user.last_name,
          pen_name: author.pen_name
        }
      }
    else
      object.authors.preview.map { |author|
        MainApp::V1::AuthorSerializer.new(author, scope: { include_user: true }).as_json
      }
    end
  end

  def include_authors?
    scope && scope[:include_authors]
  end
end
