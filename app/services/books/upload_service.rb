# frozen_string_literal: true

module Books
  class UploadService < ::ServiceBase
    def initialize(book, file_param)
      super
      @book = book
      @file_param = file_param
    end

    def call
      old_file_id = book.file_id

      service = Grpc::UploadFileClientStreamService.new(file_param[:tempfile].path, file_param[:filename]).call

      unless service.success?
        add_errors(service.errors)
        return self
      end

      book.update!(file_id: service.data.id)

      if old_file_id.present?
        service = Grpc::DeleteFileService.new(old_file_id).call

        add_errors(service.errors) unless service.success?
      end

      self
    end

    private

    attr_reader :book, :file_param
  end
end
