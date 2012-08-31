# The resque web interface
clerkweb: bundle exec thin start -R agents/clerk/web.ru -p $PORT -e ${RACK_ENV:-development}

# The resque worker
clerk: bundle exec rake --rakefile agents/clerk/clerk.rake resque:work QUEUE=* 

# The twirl runner
twirl: bundle exec ruby agents/twirl/twirl.rb -e ${RACK_ENV:-development}

# The stats worker
stats: bundle exec ruby agents/stats/stats.rb --worker

# The stats web interface
statsweb: bundle exec ruby agents/stats/stats.rb --web -p "$PORT"
