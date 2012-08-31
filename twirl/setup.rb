ENV["RACK_ENV"] ||= Bountybase.environment

Event.severity = :info
I "Starting #{Bountybase.instance} in #{Bountybase.environment} environment."

trap('TERM') do
  W "Graceful shutdown"
  exit
end

# -- startup Bountybase.metrics ---------------------------------------

Bountybase.metrics.startup!

# -- configure TweetStream --------------------------------------------

# Processing status objects is a pain in the ass. The tweetstream gem 
# changed its API considerably between 1.x and 2.x versions. Therefore
# we check the tweetstream version here, and have it locked in the Gemfile.

if TweetStream::VERSION !~ /2.1.0/
  W "Potentially unsupported TweetStream version", TweetStream::VERSION
end

TweetStream.configure(&twitter_config)

$client = TweetStream::Client.new
I "Configured TweetStream using", twitter_config.call(OpenStruct.new)

