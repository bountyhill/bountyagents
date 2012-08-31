module Dashboards
  # The Health dashboard contains metrics which should show that the 
  # entire system is working.
  def health
    gauge :heartbeats_per_hour, :tick => 1.hour
    gauge :heartbeats_per_day, :tick => 1.hour

    event :heartbeat do
      incr :heartbeats_per_hour
      incr :heartbeats_per_day
    end

    gauge :queue_length, :tick => 1.hour
    gauge :used_memory, :tick => 1.hour

    event :health do
      set_value :queue_length, data[:queue_length]
      set_value :used_memory, data[:used_memory]
    end

    widget 'Health', {
      :title => "Heartbeats",
      :type => :numbers,
      :width => 100,
      :gauges => [:heartbeats_per_hour, :heartbeats_per_day],
      :offsets => [1,3,5,10],
      :autoupdate => 120
    }

    widget 'Health', {
      :title => "Events",
      :type => :numbers,
      :width => 100,
      :gauges => [:queue_length, :used_memory],
      :offsets => [0,1,3,5],
      :autoupdate => 1
    }

    widget 'Health', {
      :title => "Event queue length",
      :type => :timeline,
      :width => 50,
      :gauges => :queue_length,
      :include_current => true,
      :autoupdate => 1
    }

    widget 'Health', {
      :title => "Event queue memory",
      :type => :timeline,
      :width => 50,
      :gauges => :used_memory,
      :include_current => true,
      :autoupdate => 1
    }
  end
end
