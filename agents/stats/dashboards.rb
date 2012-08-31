require "forwardable"

module Dashboards
  extend Forwardable
  delegate [:gauge, :event, :widget, :toplist_gauge] => :@context

  extend self

  attr_writer :context

  def build(context)
    context.hide_overview
    context.hide_active_users

    @context = context
    
    Dashboards.health
    Dashboards.performance
    Dashboards.tweets
  end
end

require_relative "dashboards/health"
require_relative "dashboards/performance"
require_relative "dashboards/tweets"
