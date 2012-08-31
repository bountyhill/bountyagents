# This file gets started by the Procfile. It attachs to the TwitterStream, 
# and sends TwitterStream events to the Processor object (which is defined
# in processor.rb).

require 'rubygems'
require 'bundler/setup'
require 'tweetstream'
require 'awesome_print'

# set default environment. This must be done *before* requiring bountybase/setup

ENV["INSTANCE"] ||= "development-bountytwirl1"

# -- set up Bountybase ------------------------------------------------

require "./vendor/bountybase/setup"

require_relative "twirl/helpers"
require_relative "twirl/processor"
require_relative "twirl/setup"

EM.run do
  # Sending a heartbeat allows us not only to track health, but 
  # to stay running, too.
  EM::PeriodicTimer.new(10) do
    Bountybase.metrics.heartbeat!
  end

  # Start tracking or sampling Twitter
  twirl_tags = Bountybase.config.twirl_tags
  twirl_tags = nil
  expect! twirl_tags => [ Array, nil ]
  
  if twirl_tags
    W "Start tracking Twitter", *twirl_tags
    $client.track(twirl_tags) do |status|
      Processor.process status
    end
  else
    W "Start sampling Twitter"
    $client.sample do |status|
      Processor.process status
    end 
  end

  # reached a limit
  $client.on_limit do |skip_count| 
    W "Twitter warning: limit reached; skipped #{skip_count} messages."
    Bountybase.metrics.twitter_limit! :skip_count => skip_count
  end

  # a user deleted a status
  $client.on_delete do |status_id, user_id| 
    Processor.on_delete(status_id, user_id)
  end

  # enhance your calm: hit some twitter limit.
  $client.on_enhance_your_calm  do || 
    W "Twitter warning: enhance your calm!"
    Bountybase.metrics.twitter_enhance_your_calm!
  end
  
  # access not authorized
  $client.on_unauthorized do || 
    E "Twitter error: Authorization for the twitter API request denied."
  end

  # some other error
  $client.on_error do |message| 
    E "Twitter error", message
  end
  
  $client.on_reconnect do |timeout, retries| 
    W "Twitter warning: reconnected"
    Bountybase.metrics.twitter_reconnected!
  end
end
