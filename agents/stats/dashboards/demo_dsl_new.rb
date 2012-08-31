module Dashboards
  # NEW DSL (v1.0 upwards)
  def demo_dsl_new
    return

    timeseries_gauge :number_of_signups,
      :group => "My Group",
      :title => "Number of Signups",
      :key_nouns => ["Singup", "Signups"],
      :series => [:via_twitter, :via_facebook],
      :resolution => 2.minutes


    distribution_gauge :user_age_distribution,
      :title => "User Age Distribution",
      :value_ranges => [(10..16), (16..20), (20..24), (24..28), (28..32), (32..36), (40..44), (44..48),
                        (48..52), (52..56), (60..64), (64..68), (68..72), (72..76), (70..74), (74..78)],
      :value_scale  => 1,
      :resolution => 2.minutes


    toplist_gauge :popular_keywords,
      :title => "Popular Keywords",
      :resolution => 2.minutes


    event :search do
      observe :popular_keywords, data[:keyword]
    end

    event :signup do
      if data[:referrer] == "facebook"
        incr :number_of_signups, :via_facebook, 1
      elsif data[:referrer] == "twitter"
        incr :number_of_signups, :via_twitter, 1
      end
    end

  end
end
