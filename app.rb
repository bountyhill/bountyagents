require 'rubygems'
require 'bundler/setup'

# get -e argument (if any)

# set environment from "INSTANCE" environment variable. This value should
# be "<environment>-<role>NN", e.g. "staging-bountytwirl1"

if ENV["INSTANCE"].to_s =~ /^(production|staging)-([a-z]+)(\d+)$/
  environment, instance, number = $1, $2, $3 
  ENV["RACK_ENV"] = environment
  STDERR.puts "Autodetected environment #{ENV["INSTANCE"]}"
end
 
require "./vendor/bountybase/setup"

Bountybase.logger.info "Starting Bountytwirl in #{Bountybase.environment} environment."

require "eventmachine"

def I(*args)
  Bountybase.logger.send :warn, *args
end

def D(*args)
  Bountybase.logger.send :info, *args
end

def safe(&block)
  yield
rescue 
  STDERR.puts "#{$!}, from\n\t#{$!.backtrace.join("\n\t")}"
end

if false

EM.run do
  EM::PeriodicTimer.new(10) do
    safe do
      Bountybase::Message::Heartbeat.enqueue
      logger.warn "heartbeat!"
    end
  end
end

end

trap('TERM') do
  STDERR.puts "Graceful shutdown"
  exit
end
