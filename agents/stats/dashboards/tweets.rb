module Dashboards
  # The Tweets dashboard.
  def tweets
    gauge :tweets_per_hour, :tick => 1.hour
    gauge :tweets_per_minute, :tick => 1.minute
    gauge :tweets_per_second, :tick => 1.second

    event :tweet do
      incr :tweets_per_hour
      incr :tweets_per_minute
      incr :tweets_per_second
    end

    gauge :lang_distribution_monthly,
      :tick => 1.month.to_i,
      :three_dimensional => true,
      :title => "Lang Distribution monthly"

    gauge :lang_distribution_daily,
      :tick => 1.day.to_i,
      :three_dimensional => true,
      :title => "Lang Distribution daily"

    event :tweet do
      incr_field(:lang_distribution_monthly, data[:lang], 1)
      incr_field(:lang_distribution_daily, data[:lang], 1)
    end

    widget 'Tweets', {
      :title => "Tweet counts",
      :type => :numbers,
      :width => 100,
      :gauges => [:tweets_per_second, :tweets_per_minute, :tweets_per_hour],
      :offsets => [1,3,5,10],
      :autoupdate => 1
    }

    widget 'Tweets', {
      :title => "Tweets per Minute",
      :type => :timeline,
      :width => 50,
      :gauges => :tweets_per_minute,
      :include_current => true,
      :autoupdate => 30
    }

    widget 'Tweets', {
      :title => "Tweets per Hour",
      :type => :timeline,
      :width => 50,
      :gauges => :tweets_per_hour,
      :include_current => true,
      :autoupdate => 30
    }

    # --- Tweet language distribution. -----------------------------------------------------------------

    widget 'Tweets', {
      :title => "Lang Distribution monthly",
      :type => :bars,
      :width => 50,
      :autoupdate => 5,
      :order_by => :field,
      :gauges => [ :lang_distribution_monthly ]
    }

    widget 'Tweets', {
      :title => "Lang Distribution daily",
      :type => :bars,
      :width => 50,
      :autoupdate => 5,
      :order_by => :field,
      :gauges => [ :lang_distribution_daily ]
    }

    # --- Top Tags

    toplist_gauge :popular_keywords,
      :title => "Popular Tags",
      :resolution => 2.minutes

    event :tweet do
      next unless data[:tags]
      data[:tags].each do |tag|
        observe :popular_keywords, tag
      end
    end
  end
end
