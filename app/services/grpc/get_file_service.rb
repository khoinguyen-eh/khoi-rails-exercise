# frozen_string_literal: true

module Grpc
  class GetFileService < Grpc::Base
    def initialize(file_id, download_url: false, remote_url: false)
      super

      @file_id = file_id
      @download_url = download_url
      @remote_url = remote_url
    end

    def call
      request = Files::GetFileRequest.new(id: @file_id, download_url: @download_url, remote_url: @remote_url)
      @data = stub.get_file(request)

      @data.download_url = FILES_SERVICE_HTTP_URL + @data.download_url if @data.download_url.present?
      @data.remote_url = FILES_SERVICE_HTTP_URL + @data.remote_url if @data.remote_url.present?

      self
    rescue GRPC::BadStatus => e
      Rails.logger.error "gRPC call failed: #{e.message}"
      add_error(e)

      self
    end
  end
end
