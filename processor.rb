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
      D "on_delete", [status_id, user_id]
    end
    
    def process(status)
      I "=== @" + status.user.screen_name, status.text

      # D "retweeted_status", status.retweeted_status
      D "urls", status.urls.map(&:expanded_url)
      D "user_mentions", status.user_mentions
      D "hashtags", status.hashtags
      D "source", status.source
      D "user_id", status.user.id
      D "location", status.user.location
      D "lang", status.user.lang
      D "screen_name", status.user.screen_name
      D "name", status.user.name
      D "profile_image", status.user.profile_image_url_https
      D "status_id", status.id
    end
  end
end