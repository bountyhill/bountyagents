require "bundler/setup"
require 'resque/tasks'

task :bountybase_setup do
  # set a default instance name
  ENV["INSTANCE"] ||= "development-bountyclerk1"

  # load bountybase
  require_relative '../../vendor/bountybase/setup'

  # Usually we would just have to require bountybase/setup. But to allow
  # for a faster startup this only initializes logging, when $0 is rake;
  # which is the case here. Therefore we have to explicitely setup Bountybase
  # once more.
  Bountybase.setup

  # Timeout interval.
  ENV['INTERVAL'] ||= "1"
  
  # see http://hone.heroku.com/resque/2012/08/21/resque-signals.html. Not that
  # we care about that so far...
  ENV['TERM_CHILD'] = "1"
  
  # Be verbose, resque!
  ENV['VERBOSE'] = "1"

  # Be really verbose, resque!
  #ENV['VVERBOSE'] = "1"
end

task "resque:setup" => :bountybase_setup
