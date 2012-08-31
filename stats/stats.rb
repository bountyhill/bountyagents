# $stdout.sync = true
require 'rubygems'
require 'bundler/setup'

# --- parse commandline -----------------------------------------------

require_relative "cli"

if !CLI.web? && !CLI.worker?
  STDERR.puts "Please add the --web and/or --worker command line arguments to determine which instance to run."
  exit 1
end

# --- get bountybase config -------------------------------------------

require "fnordmetric"
require "./vendor/bountybase/setup"

# require_relative "patches/fnordmetric/web"
# require_relative "patches/fnordmetric/web_socket"

# --- setup fnordmetric -----------------------------------------------

FnordMetric.options = {
  :event_queue_ttl  => 30, # all data that isn't processed within 10s is discarded to prevent memory overruns
  :event_data_ttl   => 30,
  :session_data_ttl => 1,  # we don't care about session data for now
  :redis_prefix     => Bountybase.config.fnordmetric["redis_prefix"],
  :redis_url        => Bountybase.config.fnordmetric["redis_url"]
}

# --- setup fnordmetric dashboard -------------------------------------

require_relative "dashboards"

FnordMetric.namespace :stats do
  Dashboards.build(self)
end

# prepare instance types. FnordMetric can run multiple instance types in 
# a single EM loop.

if CLI.web?
  W "Starting stats web at port #{CLI.options[:port]}"
  FnordMetric::Web.new(:port => CLI.options[:port])
end

if CLI.worker?
  W "Starting stats worker"
  FnordMetric::Worker.new

  # The health module generates health events every 10 seconds in a separate thread.
  require_relative "health"
  BountyHealth.start 10.seconds
end

FnordMetric.run
