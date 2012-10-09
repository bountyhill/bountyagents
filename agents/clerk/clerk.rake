require "bundler/setup"
require 'resque/tasks'

namespace :bountybase do
  task :setup do
    # set a default instance name
    ENV["INSTANCE"] ||= "development-clerk1"

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
    #ENV['VERBOSE'] = "1"

    # Be really verbose, resque!
    #ENV['VVERBOSE'] = "1"
  end

  # This starts the heartbeat timer *in a separate thread*. It can't be started
  # in the main thread, because there is no eventmachine running.
  #
  # Note that this task does not keep alive the process; it just starts
  # the thread and have it running in the background. 
  task :heartbeat => :setup do
    require "eventmachine"
    
    Thread.new do
      begin
        EM.run { Bountybase.start_heartbeat }
      rescue
        $!.log
      end
    end
  end
end

task "resque:setup" => %w(bountybase:setup bountybase:heartbeat)
