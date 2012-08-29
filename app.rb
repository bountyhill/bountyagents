# This file gets started by the Procfile. It attachs to the 
# TwitterStream, and sends "tweetstream" events to the 
# Processor object.
require 'rubygems'
require 'bundler/setup'
require 'tweetstream'
require "awesome_print"
require "pp"

require "./vendor/bountybase/setup"
require_relative "helpers"

ENV["INSTANCE"] ||= "development-bountytwirl1"
ENV["RACK_ENV"] ||= Bountybase.environment
 
# -- default logging --------------------------------------------------

Event.severity = :info
I "Starting #{Bountybase.instance} in #{Bountybase.environment} environment."

trap('TERM') do
  W "Graceful shutdown"
  exit
end

# -- configure TweetStream --------------------------------------------

# Processing status objects is a pain in the ass. The tweetstream gem changed
# its API considerably between 1.x and 2.x versions. Therefore we check the
# tweetstream version here, and have it locked in the Gemfile.

if TweetStream::VERSION !~ /2.1.0/
  W "Potentially unsupported TweetStream version", TweetStream::VERSION
end


TweetStream.configure(&twitter_config)

$client = TweetStream::Client.new
I "Configured TweetStream using", twitter_config.call(OpenStruct.new)

# -- configure tags to track ------------------------------------------

$twirl_tags = nil
# $twirl_tags = Bountybase.config.twirl_tags
W "Tracking", *$twirl_tags if $twirl_tags

require_relative "processor"

Bountybase.metrics.startup!

EM.run do
  EM::PeriodicTimer.new(10) do
    Bountybase.metrics.heartbeat!
  end

  # track or search
  if $twirl_tags
    $client.track($twirl_tags) do |status|
      Processor.process status
    end
  else
    $client.sample do |status|
      Processor.process status
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
