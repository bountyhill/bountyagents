# configuration for resque's redis server

resque_url = Bountybase.config.resque
STDERR.puts "Connecting to resque server #{resque_url}"

Resque.redis = resque_url
STDERR.puts "Connected to resque server: #{Resque.redis.ping}"
