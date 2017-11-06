module Nestful
  class Endpoint
    def self.[](url)
      self.new(url)
    end

    attr_reader :url

    def initialize(url, options = {})
      @url     = url
      @options = options
    end

    def [](suburl)
      return self if suburl.nil?
      suburl = suburl.to_s
      base   = url
      base  += "/" unless base =~ /\/$/
      self.class.new(URI.join(base, suburl).to_s, @options)
    end

    def get(params = {}, options = {})
      request(:get, params, options)
    end

    def put(params = {}, options = {})
      request(:put, params, options)
    end

    def post(params = {}, options = {})
      request(:post, params, options)
    end

    def delete(params = {}, options = {})
      request(:delete, params, options)
    end

    private

    def request(method, params, options)
      options = @options.merge(options.merge(:method => method, :params => params))
      Request.new(url, options).execute
    end
  end
end
