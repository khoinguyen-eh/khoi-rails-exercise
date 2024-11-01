# frozen_string_literal: true

module OpenAi
  class ChatCompletion < Base
    DEFAULT_MAX_TOKEN = 1000
    DEFAULT_TEMPERATURE = 1
    DEFAULT_TOP_P = 0.8
    DEFAULT_FREQUENCY_PENALTY = 1
    DEFAULT_PRESENCE_PENALTY = 0

    class << self
      def create(parameters:)
        base_client.chat(parameters: parameters)
      end

      def params(args = {})
        model_args = {
          max_tokens: DEFAULT_MAX_TOKEN, temperature: DEFAULT_TEMPERATURE, top_p: DEFAULT_TOP_P,
          frequency_penalty: DEFAULT_FREQUENCY_PENALTY, presence_penalty: DEFAULT_PRESENCE_PENALTY
        }

        model_args.merge(
          args.slice(
            :model,
            :max_tokens, :temperature, :top_p,
            :frequency_penalty, :presence_penalty, :messages, :prompt
          )
        )
      end
    end
  end
end
