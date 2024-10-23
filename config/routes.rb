# frozen_string_literal: true

Rails.application.routes.draw do
  mount MainAppAPI => '/api'
end
