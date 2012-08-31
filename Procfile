clerkweb: bundle exec thin start -R clerk.ru -p $PORT -e ${RACK_ENV:-development}
clerk: bundle exec rake --rakefile clerk.rake resque:work QUEUE=* 
twirl: bundle exec ruby twirl.rb -e ${RACK_ENV:-development}
stats: bundle exec ruby stats/stats.rb -p "$PORT"
