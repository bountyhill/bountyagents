require "trollop"

module CLI
  extend self
  
  def options
    @options ||= Trollop::options do
      version "bountystats"
      banner <<-EOS
bountystats is the statistics component for bountyhill.

  ./bountystats.rb [options]

where [options] are:
 
EOS

      opt :port, "Set PORT", :short => 'p', :type => :int, :default => 4242
    end
  end
end
