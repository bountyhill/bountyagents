require "bundler/setup"
require 'resque/tasks'

task :bountybase do
  ENV["INSTANCE"] ||= "development-bountyclerk1"
  require_relative 'vendor/bountybase/setup'
end

task "resque:setup" => :bountybase
