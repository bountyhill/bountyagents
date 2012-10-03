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

# configure TweetStream

# Returns a twitter oauth object for this instance.
$oauth = Bountybase.config.twitter[Bountybase.instance] || begin
  E "Cannot find twitter configuration for", Bountybase.instance
  exit 1
end

TweetStream.configure do |config|
  config.consumer_key       = $oauth["consumer_key"]
  config.consumer_secret    = $oauth["consumer_secret"]
  config.oauth_token        = $oauth["access_token"]
  config.oauth_token_secret = $oauth["access_token_secret"]
  config.auth_method        = :oauth
end

I "Configured TweetStream using", $oauth

$client = TweetStream::Client.new
