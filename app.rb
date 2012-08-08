require 'rubygems'
require 'bundler/setup'
require "pp"

require "./vendor/bountybase/setup"

ENV["INSTANCE"] ||= "development-bountytwirl1"
ENV["RACK_ENV"] ||= Bountybase.environment
 
# -- default logging --------------------------------------------------

Event.severity = :info

def E(*args); Bountybase.logger.send :error, *args; end
def W(*args); Bountybase.logger.send :warn, *args; end
def I(*args); Bountybase.logger.send :info, *args; end
def D(*args); Bountybase.logger.send :debug, *args; end

I "Starting #{Bountybase.instance} in #{Bountybase.environment} environment."

def safe(&block)
  yield
rescue 
  E "#{$!}, from\n\t#{$!.backtrace.join("\n\t")}"
end

trap('TERM') do
  W "Graceful shutdown"
  exit
end


# -- configure TweetStream --------------------------------------------

# Processing status objects is a pain in the ass. The tweetstream gem changed
# its API considerably between 1.x and 2.x versions. Therefore we check the
# tweetstream version here, and have it locked in the Gemfile.

require 'tweetstream'

if TweetStream::VERSION !~ /2.1.0/
  W "Potentially unsupported TweetStream version", TweetStream::VERSION
end

class OpenStruct
  def inspect
    @table.map do |k,v|
      "#{k}: #{v.inspect}"
    end.sort.join(", ")
  end
end

def twitter_config
  @twitter_config ||= begin
    config = Bountybase.config.twitter[Bountybase.instance]
    unless config
      E "Cannot find twitter configuration for", Bountybase.instance
      exit 1
    end
    OpenStruct.new config
  end
end

TweetStream.configure do |config|
  config.consumer_key       = twitter_config.consumer_key
  config.consumer_secret    = twitter_config.consumer_secret
  config.oauth_token        = twitter_config.access_token
  config.oauth_token_secret = twitter_config.access_token_secret
  config.auth_method        = :oauth
end

$client = TweetStream::Client.new
I "Configured TweetStream using", twitter_config

# -- configure tags to track ------------------------------------------

$twirl_tags = nil
$twirl_tags = Bountybase.config.twirl_tags
W "Tracking", *$twirl_tags if $twirl_tags

require_relative "processor"

EM.run do
  EM::PeriodicTimer.new(30) do
    Bountybase.metrics.heartbeat!
    # Bountybase::Message::Heartbeat.enqueue
    # I "heartbeat!"
  end

  # track or search
  if $twirl_tags
    $client.track($twirl_tags) do |status|
      Processor.on_track status
    end
  else
    $client.sample do |status|
      Processor.on_sample status
    end 
  end

  # reached a limit
  $client.on_limit do |limit| 
    W "Twitter limit reached; skipped #{skip_count} messages."
  end

  # a user deleted a status
  $client.on_delete do |status_id, user_id| 
    Processor.on_delete(status_id, user_id)
  end

  # enhance your calm: hit some twitter limit.
  $client.on_enhance_your_calm  do || 
    I "Twitter: enhance your calm!"
  end
  
  # access not authorized
  $client.on_unauthorized do || 
    E "Authorization for the twitter API request denied."
  end

  # some other error
  $client.on_error do |message| 
    E "Twitter error", message
  end
  
  $client.on_reconnect do |timeout, retries| 
    I "Reconnected"
  end
  
  $client.on_no_data_received do || 
    I "No data received"
  end
end
