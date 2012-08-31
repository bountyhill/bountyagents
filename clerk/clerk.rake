require "bundler/setup"
require 'resque/tasks'

task :bountybase_setup do
  ENV["INSTANCE"] ||= "development-bountyclerk1"
  require_relative '../vendor/bountybase/setup'
end

task "resque:setup" => :bountybase_setup
