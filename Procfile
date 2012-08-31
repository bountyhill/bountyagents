# The resque web interface
clerkweb: bundle exec thin start -R clerk/web.ru -p $PORT -e ${RACK_ENV:-development}

# The resque worker
clerk: bundle exec rake --rakefile clerk/clerk.rake resque:work QUEUE=* 

# The twirl runner
twirl: bundle exec ruby twirl.rb -e ${RACK_ENV:-development}

# The stats worker
stats: bundle exec ruby stats/stats.rb --worker

# The stats web interface
stats: bundle exec ruby stats/stats.rb --web -p "$PORT"
