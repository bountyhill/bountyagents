# $stdout.sync = true
require 'rubygems'
require 'bundler/setup'

# --- parse commandline -----------------------------------------------

require_relative "cli"
PORT = CLI.options[:port]

# --- get bountybase config -------------------------------------------

require "fnordmetric"
require "./vendor/bountybase/setup"

# require_relative "patches/fnordmetric/web"
# require_relative "patches/fnordmetric/web_socket"

# --- setup fnordmetric -----------------------------------------------

config = Bountybase.config.fnordmetric

FnordMetric.options = {
  :event_queue_ttl  => 30, # all data that isn't processed within 10s is discarded to prevent memory overruns
  :event_data_ttl   => 30,
  :session_data_ttl => 1,  # we don't care about session data for now
  :redis_prefix     => config["redis_prefix"],
  :redis_url        => config["redis_url"]
}

require_relative "dashboards"

# --- setup fnordmetric dashboard -------------------------------------

FnordMetric.namespace :stats do
  Dashboards.build(self)
end

W "Starting stats web at port #{PORT}"
FnordMetric::Web.new(:port => PORT)
FnordMetric::Worker.new

#
# The BountyHealth module defines a thread, which generates health events every 10 seconds,
require_relative "health"
BountyHealth.start 10.seconds

#
# Shoot!
FnordMetric.run
