# configuration for resque's redis server

DEFAULT_REDIS_URLS = {
  "development" =>  "localhost:12345",
  nil =>            "localhost:12345"
}

REDIS_URL = ENV["REDIS_URL"] || 
  ENV["REDISTOGO_URL"] || 
  DEFAULT_REDIS_URLS[ ENV["RAKE_ENV"] ] || 
  raise("Missing REDISTOGO_URL setting!")

STDERR.puts "Connecting to redis server #{REDIS_URL}"
STDERR.puts "Connected to redis server: #{Resque.redis.ping}"
