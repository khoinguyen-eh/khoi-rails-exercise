# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::Books, type: :api do
  let!(:book) { create(:book) }
  let!(:author) { create(:author, books: [book]) }

  describe 'GET /api/v1/books' do
    it 'returns all books with pagination' do
      get '/api/v1/books', params: { page: 1, per_page: 10 }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end

    it 'returns books with include_authors all' do
      get '/api/v1/books', params: { include_authors: 'all' }
      author_data = json_response['data']['items'].first['authors'].first

      expect(response).to have_http_status(:ok)
      expect(author_data).to have_key('id')
      expect(author_data).to have_key('pen_name')
      expect(author_data).to have_key('bio')
    end

    it 'returns books with include_authors id_only' do
      get '/api/v1/books', params: { include_authors: 'id_only' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['items'].first['authors']).to eq([author.id])
    end

    it 'returns books with include_authors id_and_pen_name' do
      get '/api/v1/books', params: { include_authors: 'id_and_pen_name' }
      authors = json_response['data']['items'].first['authors']

      expect(response).to have_http_status(:ok)
      expect(authors).to eq([{ id: author.id, pen_name: author.pen_name }.stringify_keys])
    end

    it 'returns books with include_authors id_and_all_names' do
      get '/api/v1/books', params: { include_authors: 'id_and_all_names' }
      authors = json_response['data']['items'].first['authors']

      expect(response).to have_http_status(:ok)
      expect(authors).to eq([{
                               id: author.id,
                               pen_name: author.pen_name,
                               first_name: author.user.first_name,
                               last_name: author.user.last_name
                             }.stringify_keys])
    end

    it 'returns 400 if include_authors is invalid' do
      get '/api/v1/books', params: { include_authors: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'GET /api/v1/books/:id' do
    it 'returns a specific book' do
      get "/api/v1/books/#{book.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(book.id)
    end

    it 'returns 404 if book not found' do
      get "/api/v1/books/#{book.id + 1}"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns book with include_authors all' do
      get "/api/v1/books/#{book.id}", params: { include_authors: 'all' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['authors']).not_to be_empty
    end

    it 'returns book with include_authors id_only' do
      get "/api/v1/books/#{book.id}", params: { include_authors: 'id_only' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['authors']).to eq([author.id])
    end

    it 'returns book with include_authors id_and_pen_name' do
      get "/api/v1/books/#{book.id}", params: { include_authors: 'id_and_pen_name' }
      authors = json_response['data']['authors']

      expect(response).to have_http_status(:ok)
      expect(authors).to eq([{ id: author.id, pen_name: author.pen_name }.stringify_keys])
    end

    it 'returns book with include_authors id_and_all_names' do
      get "/api/v1/books/#{book.id}", params: { include_authors: 'id_and_all_names' }
      authors = json_response['data']['authors']

      expect(response).to have_http_status(:ok)
      expect(authors).to eq([{
                               id: author.id,
                               pen_name: author.pen_name,
                               first_name: author.user.first_name,
                               last_name: author.user.last_name
                             }.stringify_keys])
    end

    it 'returns 400 if include_authors is invalid' do
      get "/api/v1/books/#{book.id}", params: { include_authors: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'POST /api/v1/books' do
    let(:book_params) {
 { isbn: '1234567890', name: 'New Book', description: 'Lorem ipsum', published_at: Time.zone.now, rating: 4.5 } }
    let(:new_author) { create(:author) }

    it 'creates a book with valid params' do
      post '/api/v1/books', params: book_params
      expect(response).to have_http_status(:created)
      expect(json_response['data']['name']).to eq('New Book')
    end

    it 'creates a book with author_ids' do
      post '/api/v1/books', params: book_params.merge(author_ids: [new_author.id])
      expect(response).to have_http_status(:created)
      expect(json_response['data']['authors']).to eq([new_author.id])
    end

    it 'returns 400 with invalid params' do
      post '/api/v1/books', params: { isbn: '', name: '', description: '', published_at: nil, rating: -1 }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end

    it 'returns 400 with invalid author_ids' do
      post '/api/v1/books', params: book_params.merge(author_ids: [new_author.id + 1])
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'PUT /api/v1/books/:id' do
    let(:update_params) {
      {
        isbn: '1234567890',
        name: 'Updated Book Title',
        description: 'Updated Description',
        rating: 5.0,
        published_at: Time.zone.now
      } }
    let(:new_author) { create(:author) }

    it 'updates a book with valid params' do
      put "/api/v1/books/#{book.id}", params: update_params
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['name']).to eq('Updated Book Title')
    end

    it 'updates a book with author_ids' do
      put "/api/v1/books/#{book.id}", params: update_params.merge(author_ids: [new_author.id])
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['authors']).to eq([new_author.id])
    end
  end

  describe 'DELETE /api/v1/books/:id' do
    it 'deletes a book' do
      delete "/api/v1/books/#{book.id}"
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if book not found' do
      delete "/api/v1/books/#{book.id + 1}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
