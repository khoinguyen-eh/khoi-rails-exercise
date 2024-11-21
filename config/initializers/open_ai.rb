# frozen_string_literal: true

module OpenAI
  class Threads
    def initialize(client:, version: "v1")
      @client = client.beta(assistants: version)
    end
  end

  class Messages
    def initialize(client:, version: "v1")
      @client = client.beta(assistants: version)
    end
  end

  class Runs
    def initialize(client:, version: "v1")
      @client = client.beta(assistants: version)
    end
  end
end
