# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::Authors, type: :api do
  let(:user) { create(:user) }
  let!(:author) { create(:author, user: user) }
  let(:another_author) { create(:author) }
  let(:book) { create(:book, authors: [author]) }

  describe 'GET /api/v1/authors' do
    it 'returns all authors with valid params' do
      get '/api/v1/authors'
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end

    it 'returns paginated authors with valid params' do
      get '/api/v1/authors', params: { page: 1, per_page: 1 }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).not_to be_empty
    end
  end

  describe 'GET /api/v1/authors/:id' do
    it 'returns an author with valid params' do
      get "/api/v1/authors/#{author.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(author.id)
    end

    it 'returns 404 if author is not found' do
      get "/api/v1/authors/#{author.id + 1}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/authors' do
    let(:author_params) {
      { pen_name: 'New Author', bio: 'Lorem ipsum', user_id: user.id }
    }
    let(:new_book) { create(:book) }

    it 'creates an author with valid params' do
      post '/api/v1/authors', params: author_params
      expect(response).to have_http_status(:created)
      expect(json_response['data']['pen_name']).to eq('New Author')
    end

    it 'returns 404 if user is not found' do
      post '/api/v1/authors', params: author_params.merge(user_id: -1)
      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).not_to be_empty
    end

    it 'returns 404 if book is not found' do
      post '/api/v1/authors', params: author_params.merge(book_ids: [new_book.id + 1])
      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).not_to be_empty
    end
  end

  describe 'PUT /api/v1/authors/:id' do
    let(:update_params) {
      {
        pen_name: 'Updated Author Name',
        bio: 'Updated Bio',
        user_id: user.id
      }
    }
    let(:new_book) { create(:book) }

    it 'updates an author with valid params' do
      put "/api/v1/authors/#{author.id}", params: update_params
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['pen_name']).to eq('Updated Author Name')
    end

    it 'returns 404 if author is not found' do
      put "/api/v1/authors/#{author.id + 1}", params: update_params
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if user is not found' do
      put "/api/v1/authors/#{author.id}", params: update_params.merge(user_id: -1)
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if author is not from this user' do
      put "/api/v1/authors/#{another_author.id}", params: update_params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/authors/:id' do
    let(:delete_params) {
      { user_id: user.id }
    }

    it 'deletes an author' do
      delete "/api/v1/authors/#{author.id}", params: delete_params
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if author is not found' do
      delete "/api/v1/authors/#{author.id + 1}", params: delete_params
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if user is not found' do
      delete "/api/v1/authors/#{author.id}", params: delete_params.merge(user_id: -1)
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if author is not from this user' do
      delete "/api/v1/authors/#{another_author.id}", params: delete_params
      expect(response).to have_http_status(:not_found)
    end
  end
end
