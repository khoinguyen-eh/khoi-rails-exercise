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

    def find_book
      Book.find(params[:id])
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
        books = Book.all
        books = books.where('rating >= ?', params[:min_rating]) if params[:min_rating].present?
        books = books.order(rating: :desc).limit(params[:limit])
        render_book(
          books,
          include_authors: params[:include_authors],
          paginate_option: {
            page: params[:page],
            per_page: params[:per_page],
            total_items: books.count
          }
        )
      end
    end

    params do
      use :author_option
      use :pagination
    end

    desc 'Get all books'
    get do
      books = Book.all.paginate(page: params[:page], per_page: params[:per_page])
      render_book(
        books,
        include_authors: params[:include_authors],
        paginate_option: {
          page: params[:page],
          per_page: params[:per_page]
        }
      )
    end

    route_param :id do
      params do
        use :author_option
      end

      desc 'Get a book'
      get do
        book = find_book
        render_book(book, include_authors: params[:include_authors])
      end
    end

    params do
      use :book_content
    end

    desc 'Create a book'
    post do
      parsed_params = declared(params)

      service = Books::CreationService.new(parsed_params)
      book = service.call

      if service.success?
        render_book(book, include_authors: book.authors.present? ? 'id_only' : nil)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :book_content
    end

    desc 'Update a book'
    put ':id' do
      book = find_book
      parsed_params = declared(params)

      service = Books::UpdateService.new(book, parsed_params)
      book = service.call

      if service.success?
        render_book(book, include_authors: book.authors.present? ? 'id_only' : nil)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    desc 'Delete a book'
    delete ':id' do
      book = find_book

      service = Books::DeletionService.new(book)
      service.call

      if service.success?
        status 204
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end
  end
end
