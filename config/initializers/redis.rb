# frozen_string_literal: true

redis_url = ENV['REDIS_CACHE_URL'] || ENV['REDIS_URL']
REDIS_CLIENT = Redis.new(url: redis_url)
