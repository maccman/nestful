module Nestful
  class Resource
    attr_reader :url
    
    def initialize(url, options = {})
      @url     = url
      @options = options
    end
    
    def [](suburl)
      self.class.new(URI.join(url, suburl).to_s)
    end
    
    def get(options = {})
      Nestful.get(url, options.merge(@options))
    end

    def post(options = {})
      Request.post(url, options.merge(@options))
    end
    
    def json_get(params = nil)
      get(:format => :json, :params => params)
    end
    
    def json_post(params = nil)
      post(:format => :json, :params => params)
    end
  end
end