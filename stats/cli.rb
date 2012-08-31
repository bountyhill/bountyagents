require "trollop"
require_relative "../vendor/bountybase/version"

module CLI
  extend self
  
  def options
    @options ||= Trollop::options do
      version "Bountyhill stats agent version #{Bountybase::VERSION}"
      banner <<-EOS
bountystats is the statistics component for bountyhill.

  ./bountystats.rb [options]

where [options] are:
 
EOS

      opt :web,     "start web server"
      opt :port,    "set web server port", :short => 'p', :type => :int, :default => 4242
      opt :worker,  "start worker"
    end
  end

  def web?
    options[:web]
  end

  def worker?
    options[:worker]
  end
end
