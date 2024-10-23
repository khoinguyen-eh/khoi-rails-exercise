# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::Authors, type: :api do
  let!(:user) { create(:user) }
  let!(:book) { create(:book) }
  let!(:author) { create(:author, books: [book], user: user) }

  describe 'GET /api/v1/authors' do
    it 'returns all authors with pagination' do
      get '/api/v1/authors', params: { page: 1, per_page: 10 }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end

    it 'returns authors with include_books all' do
      get '/api/v1/authors', params: { include_books: 'all' }
      book = json_response['data']['items'].first['books'].first

      expect(response).to have_http_status(:ok)
      expect(book).to have_key('id')
      expect(book).to have_key('name')
      expect(book).to have_key('isbn')
      expect(book).to have_key('description')
      expect(book).to have_key('rating')
      expect(book).to have_key('published_at')
    end

    it 'returns authors with include_books id_only' do
      get '/api/v1/authors', params: { include_books: 'id_only' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['items'].first['books']).to eq([book.id])
    end

    it 'returns authors with include_books id_and_name' do
      get '/api/v1/authors', params: { include_books: 'id_and_name' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['items'].first['books']).to eq([{ id: book.id, name: book.name }.stringify_keys])
    end

    it 'returns 400 if include_books is invalid' do
      get '/api/v1/authors', params: { include_books: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end

    it 'returns authors with user included' do
      get '/api/v1/authors', params: { include_user: 'true' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['items'].first['user']['id']).to eq(user.id)
    end

    it 'returns 400 if include_user is invalid' do
      get '/api/v1/authors', params: { include_user: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'GET /api/v1/authors/:id' do
    it 'returns a specific author' do
      get "/api/v1/authors/#{author.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(author.id)
    end

    it 'returns 404 if author not found' do
      get "/api/v1/authors/#{author.id + 1}"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns author with include_books all' do
      get "/api/v1/authors/#{author.id}", params: { include_books: 'all' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['books']).not_to be_empty
    end

    it 'returns author with include_books id_only' do
      get "/api/v1/authors/#{author.id}", params: { include_books: 'id_only' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['books']).to eq([book.id])
    end

    it 'returns author with include_books id_and_name' do
      get "/api/v1/authors/#{author.id}", params: { include_books: 'id_and_name' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['books']).to eq([{ id: book.id, name: book.name }.stringify_keys])
    end

    it 'returns 400 if include_books is invalid' do
      get "/api/v1/authors/#{author.id}", params: { include_books: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end

    it 'returns author with user included' do
      get "/api/v1/authors/#{author.id}", params: { include_user: 'true' }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['user']['id']).to eq(user.id)
    end

    it 'returns 400 if include_user is invalid' do
      get "/api/v1/authors/#{author.id}", params: { include_user: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'POST /api/v1/authors' do
    let(:author_params) { { pen_name: 'Pen Name', bio: 'Lorem ipsum', user_id: user.id } }
    let(:new_book) { create(:book) }

    it 'creates an author with valid params' do
      post '/api/v1/authors', params: author_params
      expect(response).to have_http_status(:created)
      expect(json_response['data']['pen_name']).to eq('Pen Name')
    end

    it 'creates an author with book_ids' do
      post '/api/v1/authors', params: author_params.merge(book_ids: [new_book.id])
      expect(response).to have_http_status(:created)
      expect(json_response['data']['books']).to eq([new_book.id])
    end

    it 'returns 400 without user_id' do
      post '/api/v1/authors', params: { pen_name: 'Pen', bio: 'Bio', user_id: nil }
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end

    it 'returns 400 with invalid book_ids' do
      post '/api/v1/authors', params: author_params.merge(book_ids: [new_book.id + 1])
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'PUT /api/v1/authors/:id' do
    let(:update_params) { { pen_name: 'Updated Pen Name', bio: 'Updated Bio' } }
    let(:new_book) { create(:book) }

    it 'updates an author with valid params' do
      put "/api/v1/authors/#{author.id}", params: update_params
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['pen_name']).to eq('Updated Pen Name')
    end

    it 'updates an author with book_ids' do
      put "/api/v1/authors/#{author.id}", params: update_params.merge(book_ids: [new_book.id])
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['books']).to eq([new_book.id])
    end

    it 'does nothing with user_id param' do
      put "/api/v1/authors/#{author.id}", params: { user_id: user.id + 1 }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['user']['id']).to eq(author.user_id)
    end
  end

  describe 'DELETE /api/v1/authors/:id' do
    it 'deletes an author' do
      delete "/api/v1/authors/#{author.id}"
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if author not found' do
      delete "/api/v1/authors/#{author.id + 1}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
