# coding: utf-8
#
# This file contains the non-resque part of the resque server app.
require "sinatra"

set :public_folder, "#{File.dirname(__FILE__)}/public"
set :static, true
set :views, "#{File.dirname(__FILE__)}/views"

get(/(.*)/) do |path|
  "Hello world"
end
