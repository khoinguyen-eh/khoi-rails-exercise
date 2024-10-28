# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::Books, type: :api do
  let(:user) { create(:user) }
  let!(:book) { create(:book, user: user) }
  let(:another_book) { create(:book) }
  let(:author) { create(:author, books: [book]) }

  describe 'GET /api/v1/books/top_rated' do
    it 'returns top rated books with valid params' do
      get '/api/v1/books/top_rated', params: { min_rating: 4.0, limit: 5 }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end

    it 'returns 400 if min_rating is out of range' do
      get '/api/v1/books/top_rated', params: { min_rating: 6.0 }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'GET /api/v1/books' do
    it 'returns all books with valid params' do
      get '/api/v1/books'
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end

    it 'returns paginated books with valid params' do
      get '/api/v1/books', params: { page: 1, per_page: 1 }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end
  end

  describe 'GET /api/v1/books/:id' do
    it 'returns a book with valid params' do
      get "/api/v1/books/#{book.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(book.id)
    end

    it 'returns 404 if book is not found' do
      get "/api/v1/books/#{book.id + 1}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/books' do
    let(:book_params) {
      { isbn: '1234567890', name: 'New Book', description: 'Lorem ipsum', published_at: Time.zone.now, rating: 4.5,
        user_id: user.id }
    }
    let(:new_author) { create(:author) }

    it 'creates a book with valid params' do
      post '/api/v1/books', params: book_params
      expect(response).to have_http_status(:created)
      expect(json_response['data']['name']).to eq('New Book')
    end

    it 'returns 404 if user is not found' do
      post '/api/v1/books', params: book_params.merge(user_id: -1)
      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).not_to be_empty
    end

    it 'returns 404 if author is not found' do
      post '/api/v1/books', params: book_params.merge(author_ids: [new_author.id + 1])
      expect(response).to have_http_status(:not_found)
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
        published_at: Time.zone.now,
        user_id: user.id
      }
    }
    let(:new_author) { create(:author) }

    it 'updates a book with valid params' do
      put "/api/v1/books/#{book.id}", params: update_params
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['name']).to eq('Updated Book Title')
    end

    it 'returns 404 if book is not found' do
      put "/api/v1/books/#{book.id + 1}", params: update_params
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if user is not found' do
      put "/api/v1/books/#{book.id}", params: update_params.merge(user_id: -1)
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if book is not from this user' do
      put "/api/v1/books/#{another_book.id}", params: update_params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/books/:id' do
    let(:delete_params) {
      { user_id: user.id }
    }

    it 'deletes a book' do
      delete "/api/v1/books/#{book.id}", params: delete_params
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if book is not found' do
      delete "/api/v1/books/#{book.id + 1}", params: delete_params
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if user is not found' do
      delete "/api/v1/books/#{book.id}", params: delete_params.merge(user_id: -1)
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if book is not from this user' do
      delete "/api/v1/books/#{another_book.id}", params: delete_params
      expect(response).to have_http_status(:not_found)
    end
  end
end
