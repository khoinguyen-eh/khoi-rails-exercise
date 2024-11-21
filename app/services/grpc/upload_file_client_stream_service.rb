# frozen_string_literal: true

module Grpc
  class UploadFileClientStreamService < Grpc::Base
    def initialize(file_path, filename)
      super
      @file_path = file_path
      @filename = filename
    end

    def call
      stream = Enumerator.new do |yielder|
        File.open(@file_path, 'rb') do |file|
          while (chunk = file.read(1024)) # Read in 1 KB chunks
            yielder << Files::UploadFileRequest.new(content: chunk)
          end
        end
      end

      @data = stub.upload_file_client_stream(stream, metadata: { 'filename' => @filename })

      self
    rescue GRPC::BadStatus => e
      Rails.logger.error "gRPC call failed: #{e.message}"
      add_error(e)

      self
    end
  end
end
