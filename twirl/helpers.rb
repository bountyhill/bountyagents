# Some helper methods.

# A better inspect for OpenStruct
class OpenStruct
  def inspect
    @table.map do |k,v|
      "#{k}: #{v.inspect}"
    end.sort.join(", ")
  end
end

# Returns a twitter oauth object for this instance.
def twitter_config
  oauth = Bountybase.config.twitter[Bountybase.instance]
  
  if !oauth
    E "Cannot find twitter configuration for", Bountybase.instance
    exit 1
  end

  Proc.new do |config|
    config.consumer_key       = oauth["consumer_key"]
    config.consumer_secret    = oauth["consumer_secret"]
    config.oauth_token        = oauth["access_token"]
    config.oauth_token_secret = oauth["access_token_secret"]
    config.auth_method        = :oauth
  end
end
