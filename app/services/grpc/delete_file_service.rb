# frozen_string_literal: true

module Grpc
  class DeleteFileService < Grpc::Base
    def initialize(file_id)
      super

      @file_id = file_id
    end

    def call
      request = Files::DeleteFileRequest.new(id: @file_id)
      @data = stub.delete_file(request)

      self
    rescue GRPC::BadStatus => e
      Rails.logger.error "gRPC call failed: #{e.message}"
      add_error(e)
    end
  end
end
