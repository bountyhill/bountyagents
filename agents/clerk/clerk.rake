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

  # Be really verbose, resque!
  ENV['VERBOSE'] = "1"
  ENV['VVERBOSE'] = "1"
end

task "resque:setup" => :bountybase_setup
