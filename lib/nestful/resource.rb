module Nestful
  class Resource
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
    
    def get(options = {})
      Nestful.get(url, options.merge(@options))
    end

    def post(options = {})
      Nestful.post(url, options.merge(@options))
    end
    
    def json_get(params = nil)
      get(:format => :json, :params => params)
    end
    
    def json_post(params = nil)
      post(:format => :json, :params => params)
    end
    
    def request(options = {})
      Request.new(url, options.merge(@options)).execute
    end
  end
end
