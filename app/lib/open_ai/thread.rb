# frozen_string_literal: true

module OpenAi
  class Thread < Base
    class << self
      def create_thread(params = {}, version = DEFAULT_ASSISTANT_VERSION)
        base_client(version).create(parameters: params)
      end

      private

      def base_client(version = DEFAULT_ASSISTANT_VERSION)
        OpenAI::Threads.new(client: client, version: version)
      end
    end
  end
end
