module Dashboards
  # -- The tweet_stats dashboard
  def tweet_stats
    return

    gauge :tweets_per_day, :tick => 1.day
    gauge :tweets_per_hour, :tick => 1.hour
    gauge :tweets_per_minute, :tick => 1.minute

    event :"*" do
      incr :tweets_per_day
      incr :tweets_per_hour
      incr :tweets_per_minute
    end

    widget 'TweetStats', {
      :title => "Tweets per Minute",
      :type => :timeline,
      :width => 100,
      :gauges => :tweets_per_minute,
      :include_current => true,
      :autoupdate => 30
    }

    widget 'TweetStats', {
      :title => "Tweets per Hour",
      :type => :timeline,
      :width => 50,
      :gauges => :tweets_per_hour,
      :include_current => true,
      :autoupdate => 30
    }

    widget 'TweetStats', {
      :title => "Tweets per Day",
      :type => :timeline,
      :width => 50,
      :gauges => :tweets_per_day,
      :include_current => true,
      :autoupdate => 1
    }
  end
end


