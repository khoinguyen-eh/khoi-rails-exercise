# frozen_string_literal: true

module OpenAi
  class Message < Base
    class << self
      def get_list_thread_messages(thread_id:, version: DEFAULT_ASSISTANT_VERSION)
        base_client(version).list(thread_id: thread_id)
      end

      private

      def base_client(version = DEFAULT_ASSISTANT_VERSION)
        OpenAI::Messages.new(client: client, version: version)
      end
    end
  end
end
