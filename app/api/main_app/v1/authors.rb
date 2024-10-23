# frozen_string_literal: true

class MainApp::V1::Authors < ApplicationAPI
  helpers do
    params :book_option do
      optional :include_books, type: String, values: %w[id_only id_and_name all]
    end

    params :user_option do
      optional :include_user, type: String, values: %w[true]
    end

    params :author_content do
      optional :pen_name, type: String, default: ''
      optional :bio, type: String, default: ''
      optional :is_verified, type: Boolean, default: false
      optional :book_ids, type: Array[Integer]
    end

    def find_author
      Author.find(params[:id])
    end

    def render_author(author, include_books: nil, include_user: false, paginate_option: {})
      paginated_result = paginate_option.present? ? author.paginated_result(paginate_option) : {}

      GoogleJsonResponse.render(
        author,
        serializer_klass: MainApp::V1::AuthorSerializer,
        custom_data: {
          each_serializer_options: {
            scope: {
              include_books: include_books,
              include_user: include_user
            }
          }
        }.merge(paginated_result)
      )
    end
  end

  resource :authors do
    params do
      use :book_option
      use :user_option
    end

    desc 'Get all authors'
    get do
      authors = Author.all.paginate(page: params[:page], per_page: params[:per_page])
      render_author(
        authors,
        include_books: params[:include_books],
        include_user: params[:include_user],
        paginate_option: {
          page: params[:page],
          per_page: params[:per_page]
        }
      )
    end

    route_param :id do
      params do
        use :book_option
        use :user_option
      end

      desc 'Get an author'
      get do
        author = find_author
        render_author(author, include_books: params[:include_books], include_user: params[:include_user])
      end
    end

    params do
      requires :user_id, type: Integer
      use :author_content
    end

    desc 'Create an author'
    post do
      parsed_params = declared(params)

      service = Authors::CreationService.new(parsed_params)
      author = service.call

      if service.success?
        render_author(author, include_books: author.books.present? ? 'id_only' : nil, include_user: true)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :author_content
    end

    desc 'Update an author'
    put ':id' do
      author = find_author
      parsed_params = declared(params)

      service = Authors::UpdateService.new(author, parsed_params)
      author = service.call

      if service.success?
        render_author(author, include_books: author.books.present? ? 'id_only' : nil, include_user: true)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    desc 'Delete an author'
    delete ':id' do
      author = find_author

      service = Authors::DeletionService.new(author)
      service.call

      if service.success?
        status 204
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end
  end
end
