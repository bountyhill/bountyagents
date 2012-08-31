clerkweb: bundle exec thin start -R clerk.ru -p $PORT -e ${RACK_ENV:-development}
clerk: bundle exec rake --rakefile clerk.rake resque:work QUEUE=* 
# web: bundle exec thin start -e development -p 9292
# clock: bundle exec clockwork app/clock.rb
