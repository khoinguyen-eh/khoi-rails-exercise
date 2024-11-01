# frozen_string_literal: true

module OpenAi
  class File < Base
    class << self
      def upload(parameters:)
        base_client.upload(parameters: parameters)
      end

      def retrieve_content(file_id:)
        base_client.content(id: file_id)
      end

      def delete(file_id:)
        base_client.delete(id: file_id)
      end

      private

      def base_client
        client.files
      end
    end
  end
end
