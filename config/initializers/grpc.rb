# frozen_string_literal: true

Dir[Rails.root.join('lib/**/*_services_pb.rb')].sort.each do |file|
  require file
end

Dir[Rails.root.join('lib/**/*_pb.rb')].sort.each do |file|
  require file
end

FILES_SERVICE_GRPC_HOST = ENV['FILES_SERVICE_GRPC_HOST'] || "localhost:50091"
FILES_SERVICE_HTTP_URL = ENV['FILES_SERVICE_HTTP_URL'] || "http://localhost:4000"
