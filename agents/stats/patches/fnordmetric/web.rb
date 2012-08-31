class FnordMetric::Web

  def initialize(opts)
    @opts = opts

    @opts[:server] ||= "thin"
    @opts[:host]   ||= "0.0.0.0"
    @opts[:port]   ||= "4242"

    FnordMetric.register(self)
  end

  def initialized
    server = @opts[:server].downcase

    middleware_stack = @opts[:use] || []

    websocket = FnordMetric::WebSocket.new
    webapp    = FnordMetric::App.new(@opts)

    dispatch  = Rack::Builder.app do
      use Rack::CommonLogger
      use Rack::ShowExceptions

      map "/stream" do
        run websocket
      end

      map "/" do
        middleware_stack.each do |middleware| 
          use(*middleware[0..1], &middleware[2])
        end

        run webapp
      end
    end

    unless ["thin", "hatetepe"].include? server
      raise "Need an EventMachine webserver, but #{server} isn't"
    end

    host = @opts[:host] 
    port = @opts[:port]

    STDERR.puts "**** Starting Rack::Server"

    Rack::Server.start(
      :app => dispatch,
      :server => server,
      :Host => host, 
      :Port => port,
      :host => host, 
      :port => port
    ) && FnordMetric.log("listening on http://#{host}:#{port}")
  end

end
