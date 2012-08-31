class FnordMetric::API
  def health
    {
      :used_memory => @redis.info["used_memory"].to_i,
      :queue_length => queue_length
    }
  end

  def queue_length
    prefix = @@opts[:redis_prefix]
    @redis.llen "#{prefix}-queue"
  end
end

module BountyHealth
  extend self
  
  attr :api
  
  def start(interval = 10)
    redis_url, redis_prefix = *Bountybase.config.fnordmetric.values_at("redis_url", "redis_prefix")
    @api = FnordMetric::API.new :redis_url => redis_url, :redis_prefix => redis_prefix

    Thread.new do
      loop do
        send_health_event
        sleep interval
      end
    end
  end
  
  def send_health_event
    health = api.health
    api.event health.merge(:_type => :health)
  rescue
    Bountybase.logger.error $!.to_s
  end
end
