class FnordMetric::WebSocket < Rack::WebSocket::Application

  def initialize
    super

    @reactor = FnordMetric::Reactor.new
    @uuid = "websocket-#{get_uuid}"
  end

  def on_open(env)
    STDERR.puts "websocket opened"
    # socket openened :)
  end

  def on_message(env, message)
    begin
      message = JSON.parse(message)
      STDERR.puts "websocket", message.inspect
    rescue
      STDERR.puts "websocket: invalid json"
    else
      message["_eid"] ||= get_uuid
      message["_sender"] = @uuid

      @reactor.execute(self, message).each do |m|
        send_data m.to_json
      end
    end
  end

  def get_uuid
    rand(8**64).to_s(36)
  end
end
