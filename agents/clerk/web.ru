# coding: utf-8
#
# This file is used by Rack-based servers to start the resque web server.

require "rubygems"
require "bundler/setup"

require "./vendor/bountybase/setup"

require "resque/server"

load "#{File.dirname(__FILE__)}/web.rb"

if true
  # run only the Resque server
  run Resque::Server.new 
else
  run Sinatra::Application
  # run Rack::URLMap.new(
  #     "/" => Sinatra::Application,
  #     "/resque" => Resque::Server.new 
  # )
end
