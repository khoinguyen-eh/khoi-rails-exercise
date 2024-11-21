# frozen_string_literal: true

module Grpc
  class Base < ServiceBase
    attr_reader :data

    def initialize(*_args)
      super

      @stub = Files::RpcServer::Stub.new(FILES_SERVICE_GRPC_HOST, :this_channel_is_insecure)
    end

    protected

    attr_reader :stub
  end
end
