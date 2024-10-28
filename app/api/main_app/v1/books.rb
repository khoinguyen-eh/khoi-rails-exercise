# frozen_string_literal: true

class MainApp::V1::Books < ApplicationAPI
  helpers do
    params :author_option do
      optional :include_authors, type: String, values: %w[id_only id_and_pen_name id_and_all_names all]
    end

    params :book_content do
      requires :isbn, type: String
      requires :name, type: String
      requires :description, type: String
      requires :rating, type: Float
      requires :published_at, type: Date
      optional :author_ids, type: Array[Integer]
    end

    params :pagination do
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 10
    end

    params :mock_authenticate do
      requires :user_id, type: Integer
    end

    def book
      Book.find(params[:id])
    end

    def creator
      User.find(params[:user_id])
    end

    def render_book(book, include_authors: nil, paginate_option: {})
      paginated_result = paginate_option.present? ? book.paginated_result(paginate_option) : {}

      GoogleJsonResponse.render(
        book,
        serializer_klass: MainApp::V1::BookSerializer,
        custom_data: {
          each_serializer_options: {
            scope: {
              include_authors: include_authors
            }
          }
        }.merge(paginated_result)
      )
    end
  end

  resource :books do
    resource :top_rated do
      params do
        use :author_option
        use :pagination
        optional :limit, type: Integer, default: 10
        optional :min_rating, type: Float, values: 0.0..5.0
      end

      desc 'Get top rated books'
      get do
        service = Books::GetService.new(params[:page], params[:per_page],
                                        top_rated: { limit: params[:limit], min_rating: params[:min_rating] })
        books = service.call

        if service.success?
          render_book(
            books,
            include_authors: params[:include_authors],
            paginate_option: {
              page: params[:page],
              per_page: params[:per_page]
            }
          )
        else
          error!(GoogleJsonResponse.render_error(service.errors), 400)
        end
      end
    end

    params do
      use :author_option
      use :pagination
    end

    desc 'Get all books'
    get do
      service = Books::GetService.new(params[:page], params[:per_page])
      books = service.call

      if service.success?
        render_book(
          books,
          include_authors: params[:include_authors],
          paginate_option: {
            page: params[:page],
            per_page: params[:per_page]
          }
        )
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    route_param :id do
      params do
        use :author_option
      end

      desc 'Get a book'
      get do
        render_book(book, include_authors: params[:include_authors])
      end
    end

    params do
      use :book_content
      use :mock_authenticate
    end

    desc 'Create a book'
    post do
      service = Books::CreationService.new(creator, declared(params))
      book = service.call

      if service.success?
        render_book(book, include_authors: book.authors.present? ? 'id_only' : nil)
      elsif service.has_error_class?(ActiveRecord::RecordNotFound)
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :book_content
      use :mock_authenticate
    end

    desc 'Update a book'
    put ':id' do
      service = Books::UpdateService.new(creator, params[:id], declared(params))
      book = service.call

      if service.success?
        render_book(book, include_authors: book.authors.present? ? 'id_only' : nil)
      elsif service.has_error_class?(ActiveRecord::RecordNotFound)
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :mock_authenticate
    end

    desc 'Delete a book'
    delete ':id' do
      service = Books::DeletionService.new(creator, params[:id])
      service.call

      if service.success?
        status 204
      else
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      end
    end
  end
end
