class Tweet
  def initialize(status)
    @status = status
  end
  def url
    return "http://twitter.com/#{@status['user']['screen_name']}/status/#{@status['id']}"
  end
  def text
    return @status['text']
  end
end
