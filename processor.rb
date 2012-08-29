# The Processor object receives notifications for twitter-related 
# events from eventmachine's event loop. It handles these events in its
# process method.
#
# The Processor object itself does not define the process method itself.
# Instead it redirects all messages to the Processor::Implementation 
# module, making sure all exceptions be properly logged.
module Processor

  def self.method_missing(sym, *args) #:nodoc:
    Implementation.send sym, *args
  rescue 
    E "#{$!}, from\n\t#{$!.backtrace.join("\n\t")}"
  end

  # the "raw" implementations.
  module Implementation
    extend self

    def quest_tag?(tag)
      # %w(bhill bountyhill).include?(tag)
      true
    end
    
    def on_delete(status_id, user_id)
      I "on_delete", [status_id, user_id]
    end
    
    def process(status)
      source = status.retweeted_status
        
      # Is this a quest URL?
      expanded_urls = status.urls.map(&:expanded_url).uniq
      return if expanded_urls.empty?

      hashtags = status.hashtags.map(&:text).uniq
      return unless hashtags.any? { |tag| quest_tag?(tag) }

      receivers = status.user_mentions.map do |user_mention|
        OpenStruct.new :id => user_mention.id, :name => user_mention.screen_name
      end

      t = {
        :tweet_id     => status.id,                         # id of the tweet 
        :sender_id    => status.user.id,                    # user id of the sender of this tweet 
        :sender_name  => status.user.screen_name,           # screen name of the sender of this tweet 
        :quest_urls   => expanded_urls,                     # The url for the quest.
        :text         => status.text,                       # The tweet text
        :lang         => status.user.lang,                  # The tweet language
        :app          => status.source                      # Which app was used (or "web").
      }
      
      # known source?
      if source
        t.update :source_id   => source.user.id,            # user id of the sender's source.
                 :source_name => source.user.screen_name    # screen name of the sender's source.
      end
      
      # additional receivers?
      unless receivers.empty?
        t.update :receiver_ids => receivers.map(&:id),      # An array of ids of additional receivers.
                 :receiver_names => receivers.map(&:name)   # An array of screen names of additional receivers
      end
      
      E status.text
      Bountybase::Message::Tweet.enqueue t
      ap t
      Bountybase.metrics.tweet! :lang => status.user.lang, :tags => hashtags
    end
  end
end

__END__
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
