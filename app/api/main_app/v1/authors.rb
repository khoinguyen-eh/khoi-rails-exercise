# frozen_string_literal: true

class MainApp::V1::Authors < ApplicationAPI
  helpers do
    params :book_option do
      optional :include_books, type: String, values: %w[id_only id_and_name all]
    end

    params :author_content do
      optional :pen_name, type: String, default: ''
      optional :bio, type: String, default: ''
      optional :is_verified, type: Boolean, default: false
      optional :book_ids, type: Array[Integer]
    end

    params :pagination do
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 10
    end

    params :mock_authenticate do
      requires :user_id, type: Integer
    end

    def author
      @author ||= Author.find(params[:id])
    end

    def creator
      @creator ||= User.find(params[:user_id])
    end

    def render_author(author, include_books: nil, paginate_option: {})
      paginated_result = paginate_option.present? ? author.paginated_result(paginate_option) : {}

      GoogleJsonResponse.render(
        author,
        serializer_klass: MainApp::V1::AuthorSerializer,
        custom_data: {
          each_serializer_options: {
            scope: {
              include_books: include_books
            }
          }
        }.merge(paginated_result)
      )
    end
  end

  resource :authors do
    params do
      use :pagination
      use :book_option
    end

    desc 'Get all authors'
    get do
      service = Authors::GetService.new(params[:page], params[:per_page])
      authors = service.call

      if service.success?
        render_author(authors, include_books: params[:include_books], paginate_option: {
          page: params[:page],
          per_page: params[:per_page]
        })
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    route_param :id do
      params do
        use :book_option
      end

      desc 'Get an author'
      get do
        render_author(author, include_books: params[:include_books])
      end
    end

    params do
      use :mock_authenticate
      use :author_content
    end

    desc 'Create an author'
    post do
      service = Authors::CreationService.new(creator, declared(params))
      author = service.call

      if service.success?
        render_author(author, include_books: author.books.present? ? 'id_only' : nil)
      elsif service.has_error_class?(ActiveRecord::RecordNotFound)
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :mock_authenticate
      use :author_content
    end

    desc 'Update an author'
    put ':id' do
      service = Authors::UpdateService.new(creator, params[:id], declared(params))
      author = service.call

      if service.success?
        render_author(author, include_books: author.books.present? ? 'id_only' : nil)
      elsif service.has_error_class?(ActiveRecord::RecordNotFound)
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :mock_authenticate
    end

    desc 'Delete an author'
    delete ':id' do
      service = Authors::DeletionService.new(creator, params[:id])
      service.call

      if service.success?
        status 204
      else
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      end
    end
  end
end
