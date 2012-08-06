require 'rubygems'
require 'bundler/setup'

ENV["INSTANCE"] = "bountytwirl"

STDERR.puts "environment"
STDERR.puts environment.inspect
STDERR.puts "--" * 60
 
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

EM.run do
  EM::PeriodicTimer.new(1) do
    safe do
      Bountybase::Message::Heartbeat.enqueue
      logger.warn "heartbeat!"
    end
  end
end
