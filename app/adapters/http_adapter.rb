class HttpAdapter
  Failed = Class.new(StandardError)

  def get(url)
    response = HTTParty.get(url)
    raise Failed.new("Request finished with #{response.code} status code") if response.code > 399
    response.body
  end
end
