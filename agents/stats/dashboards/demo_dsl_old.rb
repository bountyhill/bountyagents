module Dashboards
  # OLD DSL (will be supported forever, allows finer-grained control)
  def demo_dsl_old
    return

    gauge :pageviews_daily_unique, :tick => 1.day.to_i, :unique => true, :title => "Unique Visits (Daily)"
    gauge :pageviews_hourly_unique, :tick => 1.hour.to_i, :unique => true, :title => "Unique Visits (Hourly)"
    gauge :pageviews_monthly_unique, :tick => 40.days.to_i, :unique => true, :title => "Unique Visits (Month)"

    gauge :messages_sent, :tick => 1.day.to_i, :title => "Messages (sent)"
    gauge :messages_read, :tick => 1.day.to_i, :title => "Messages (read)"
    gauge :winks_sent, :tick => 1.day.to_i, :title => "Winks sent"

    gauge :pageviews_per_url_daily,
      :tick => 1.day.to_i,
      :title => "Daily Pageviews per URL",
      :three_dimensional => true

    gauge :pageviews_per_url_monthly,
      :tick => 30.days.to_i,
      :title => "Monthly Pageviews per URL",
      :three_dimensional => true

    event :_pageview do
      incr :pageviews_daily_unique
      incr :pageviews_hourly_unique
      incr :pageviews_monthly_unique
      incr_field :pageviews_per_url_daily, data[:url]
      incr_field :pageviews_per_url_monthly, data[:url]
    end


    # --- The Age Distribution dashboard. -----------------------------------------------------------------

    gauge :age_distribution_female_monthly,
      :tick => 1.month.to_i,
      :three_dimensional => true,
      :title => "Age Distribution (female) monthly"

    gauge :age_distribution_male_monthly,
      :tick => 1.month.to_i,
      :three_dimensional => true,
      :title => "Age Distribution (male) monthly"

    gauge :age_distribution_female_daily,
      :tick => 1.day.to_i,
      :three_dimensional => true,
      :title => "Age Distribution (female) daily"

    gauge :age_distribution_male_daily,
      :tick => 1.day.to_i,
      :three_dimensional => true,
      :title => "Age Distribution (male) daily"

    widget 'Demography', {
      :title => "Age Distribution: Female Users (Monthly)",
      :type => :bars,
      :width => 50,
      :autoupdate => 5,
      :order_by => :field,
      :gauges => [ :age_distribution_female_monthly ]
    }

    widget 'Demography', {
      :title => "Age Distribution: Male Users (Monthly)",
      :type => :bars,
      :width => 50,
      :autoupdate => 5,
      :order_by => :field,
      :gauges => [ :age_distribution_male_monthly ]
    }


    widget 'Demography', {
      :title => "Age Distribution: Female Users",
      :type => :toplist,
      :width => 50,
      :autoupdate => 5,
      :gauges => [ :age_distribution_female_monthly, :age_distribution_female_daily ]
    }

    widget 'Demography', {
      :title => "Age Distribution: Male Users",
      :type => :toplist,
      :width => 50,
      :autoupdate => 5,
      :gauges => [ :age_distribution_male_monthly, :age_distribution_male_daily ]
    }

    event "user_demography" do
      if data[:gender] == "female"
        incr_field(:age_distribution_female_monthly, data[:age], 1)
        incr_field(:age_distribution_female_daily, data[:age], 1)
      end
      if data[:gender] == "male"
        incr_field(:age_distribution_male_monthly, data[:age], 1)
        incr_field(:age_distribution_male_daily, data[:age], 1)
      end
      observe :user_age_distribution, data[:age]
    end
  end
end
