# The Processor object receives notifications for twitter-related 
# events from eventmachine's event loop. It handles these events in its
# on_delete and process methods.
module Processor
  extend self
  
  # The Processor object itself does not define any methods. It redirects all
  # events to the Processor::Implementation module, making sure that all
  # exceptions are properly logged.
  def method_missing(sym, *args)
    safe do 
      Implementation.send sym, *args
    end
  end

  # the "raw" implementations.
  module Implementation
    extend self

    def on_delete(status_id, user_id)
      I "on_delete", [status_id, user_id]
    end
    
    def process(status)
      W status.text
      
      hashtags, screen_names, expanded_urls = 
        status.hashtags.texts, status.user_mentions.screen_names, status.urls.expanded_urls

      expanded_url = expanded_urls.first
      #return if expanded_url.nil?
      #return if hashtags.empty?

      W "expanded_url", expanded_urls
      W "hashtags", hashtags
      
      expanded_url = expanded_urls.first
      
      tweet = {
        :tweet_id     => status.id,         # The id of the tweet 
        :sender_id    => status.user.id,    # The twitter user id of the user sent this tweet 
        :sender_name  => status.user.screen_name, # The twitter screen name of the user sent this tweet 
        # :source_id    => [Integer, nil],  # The twitter user id of the user from where the sender knows about this bounty.
        # :source_name  => [String, nil],   # The twitter screen name of the user from where the sender knows about this bounty.
        :quest_url    => expanded_url,      # The urls for the quest.
        # :receiver_ids => [Array, nil],    # An array of user ids of twitter users, that also receive this tweet.
        # :receiver_names => [Array, nil],  # An array of screen names of twitter users, that also receive this tweet.
        :text         => status.text,       # The tweet text
        :lang         => status.user.lang   # The tweet language
      }
      
      W "tweet", tweet
        
      # Bountybase::Message::Tweet.enqueue tweet

      # Bountybase.metrics.tweet! :lang => status.user.lang, :tags => hashtags

      # Bountybase.metrics.tweet_sampled!
    end
  end
end
__END__

    def on_track(status)
      on_sample(status)
      return
      
      hashtags, screen_names, expanded_urls = 
        status.hashtags.texts, status.user_mentions.screen_names, status.urls.expanded_urls
      
      I status.user.screen_name, status.text
      D "hashtags/screen_names/expanded_urls", hashtags, screen_names, expanded_urls
      
      Bountybase.metrics.tweet_tracked!
      
      (hashtags & $twirl_tags).each do |tag|
        Bountybase.metrics.count!("tweet_#{tag}")
      end
    end
    
    def __process(status)
      # Processing status objects is a pain in the ass. The tweetstream gem changed
      # its API considerably between 1.x and 2.x versions. The code below should work
      # fine with versions 2.1.x; and that is the reason that its version is pinned
      # in the Gemfile
      W "=== @" + status.user.screen_name, status.text
      #return
      # return
      
      # I "retweeted_status", status.retweeted_status
      I "urls", status.urls.map(&:expanded_url)
      I "user_mentions", status.user_mentions
      I "hashtags", status.hashtags
      I "source", status.source
      I "user_id", status.user.id
      I "location", status.user.location
      I "lang", status.user.lang
      I "screen_name", status.user.screen_name
      I "name", status.user.name
      I "profile_image", status.user.profile_image_url_https
      I "status_id", status.id
    end                                                                      
  end
end
