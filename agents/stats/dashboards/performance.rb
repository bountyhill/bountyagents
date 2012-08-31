module Dashboards
  # The Performane dashboard.
  def performance
    gauge :events_per_hour, :tick => 1.hour
    gauge :events_per_minute, :tick => 1.minute
    gauge :events_per_second, :tick => 1.second
    # gauge :processing_per_second, :average => true, :tick => 1.second 

    event :"*" do
      incr :events_per_hour
      incr :events_per_minute
      incr :events_per_second
    end

    # widget 'TechStats', {
    #   :title => "processing per second",
    #   :type => :timeline,
    #   :width => 100,
    #   :height => 500,
    #   :gauges => :processing_per_second,
    #   :include_current => false,
    #   :autoupdate => 1
    # }

    widget 'TechStats', {
      :title => "Events Numbers",
      :type => :numbers,
      :width => 100,
      :gauges => [:events_per_second, :events_per_minute, :events_per_hour],
      :offsets => [0,1,3,10],
      :autoupdate => 1
    }

    widget 'TechStats', {
      :title => "Events per Hour",
      :type => :timeline,
      :width => 100,
      :gauges => :events_per_hour,
      :include_current => false,
      :autoupdate => 30
    }

    widget 'TechStats', {
      :title => "Events per Minute",
      :type => :timeline,
      :width => 50,
      :gauges => :events_per_minute,
      :include_current => false,
      :autoupdate => 30
    }

    widget 'TechStats', {
      :title => "Events/Second",
      :type => :timeline,
      :width => 50,
      :gauges => :events_per_second,
      :include_current => false,
      #:plot_style => :areaspline,
      :autoupdate => 1
    }
  end
end


