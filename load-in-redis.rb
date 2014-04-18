#!/usr/bin/env ruby
require "json"
require "redis"

redis = Redis.new(host: ENV['REDIS_HOST'], db: ENV['REDIS_DB'])
target_key = "openproxy:list"

while STDIN.gets
  proxy = JSON.parse $_
  redis.lpush("#{target_key}:temp", "#{proxy['proxy_host']}:#{proxy['proxy_port']}")
end

redis.multi do
  redis.del "#{target_key}:old"
  redis.rename "#{target_key}", "#{target_key}:old" if redis.exists target_key
  redis.rename "#{target_key}:temp", "#{target_key}"
end

$stderr.puts "Collected #{redis.llen(target_key)} proxies"