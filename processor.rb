# Some helpers that are used only here.
class Array
  def texts               #:nodoc:
    map(&:text)
  end

  def screen_names        #:nodoc:
    map(&:screen_name)
  end

  def expanded_urls       #:nodoc:
    map(&:expanded_url)
  end
end

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
    
    def on_sample(status)
      hashtags, screen_names, expanded_urls = 
        status.hashtags.texts, status.user_mentions.screen_names, status.urls.expanded_urls

      return if hashtags.empty? && screen_names.empty? && expanded_urls.empty?
      
      I status.user.screen_name, status.text

      I "  hashtags", hashtags
      I "  screen_names", screen_names
      I "  expanded_urls", expanded_urls

      Bountybase.metrics.tweet_sampled!
    end
    
    def on_track(status)
      hashtags, screen_names, expanded_urls = 
        status.hashtags.texts, status.user_mentions.screen_names, status.urls.expanded_urls
      
      I status.user.screen_name, status.text
      D "hashtags/screen_names/expanded_urls", hashtags, screen_names, expanded_urls
      
      Bountybase.metrics.tweet_tracked!
      
      hashtags.each do |tag|
        Bountybase.metrics.count!("tweet_#{tag}")
      end
    end
    
    def process(status)
      # Processing status objects is a pain in the ass. The tweetstream gem changed
      # its API considerably between 1.x and 2.x versions. The code below should work
      # fine with versions 2.1.x; and that is the reason that its version is pinned
      # in the Gemfile
      I "=== @" + status.user.screen_name, status.text
      #return
      
      # I "retweeted_status", status.retweeted_status
      safe { I "urls", status.urls.map(&:expanded_url)                       }
      safe { I "user_mentions", status.user_mentions                         }
      safe { I "hashtags", status.hashtags                                   }
      safe { I "source", status.source                                       }
      safe { I "user_id", status.user.id                                     }
      safe { I "location", status.user.location                              }
      safe { I "lang", status.user.lang                                      }
      safe { I "screen_name", status.user.screen_name                        }
      safe { I "name", status.user.name                                      }
      safe { I "profile_image", status.user.profile_image_url_https          }
      safe { I "status_id", status.id                                        }
    end                                                                      
  end
end