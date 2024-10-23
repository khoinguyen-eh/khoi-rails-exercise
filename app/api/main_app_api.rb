# frozen_string_literal: true

class MainAppAPI < ApplicationAPI
  mount MainApp::V1::API
end
