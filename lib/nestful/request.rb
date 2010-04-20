module Nestful
  class Request
    def self.callbacks(type = nil) #:nodoc:
      @callbacks ||= {}
      return @callbacks unless type
      @callbacks[type] ||= []
    end
    
    attr_reader :url, :options, :format
    attr_accessor :params, :body, :buffer, :method, :headers, :callbacks
    
    # Connection options
    attr_accessor :proxy, :user, :password, :auth_type, :timeout, :ssl_options
  
    def initialize(url, options = {})
      @url     = url
      @options = options
      @options.each {|key, val| 
        method = "#{key}="
        send(method, val) if respond_to?(method)
      }
      self.method  ||= :get
      self.format  ||= :blank
      self.headers ||= {}
      self.params  ||= {}
      self.body    ||= ''
    end
    
    def format=(mime_or_format)
      @format = mime_or_format.is_a?(Symbol) ?
        Formats[mime_or_format] : mime_or_format
    end
    
    def connection
      conn              = Connection.new(uri, format)
      conn.proxy        = proxy if proxy
      conn.user         = user if user
      conn.password     = password if password
      conn.auth_type    = auth_type if auth_type
      conn.timeout      = timeout if timeout
      conn.ssl_options  = ssl_options if ssl_options
      conn
    end
    
    def uri
      http_url = url.match(/^http/) ? url : "http://#{url}"
      uri      = URI.parse(http_url)
      uri.path = "/" if uri.path.empty?
      if format && format.extension
        uri.path += ".#{format.extension}" 
      end      
      uri
    end
        
    def path
      uri.path
    end
    
    def query_path
      query_path = path
      if params.any?
        query_path += "?"
        query_path += params.to_param
      end
      query_path
    end
    
    def execute
      callback(:before_request, self)
      result = nil
      if [:post, :put].include?(method)
        connection.send(method, path, encoded, headers) {|res| result = decoded(res) }
      else
        connection.send(method, query_path, headers) {|res| result = decoded(res) }
      end
      callback(:after_request, self, result)
      result
    end
            
    protected    
      def encoded
        format.encode(params.any? ? params : body)
      end

      def decoded(result)
        if buffer
          data  = Tempfile.new("nfr.#{rand(1000)}")
          size  = 0
          total = result.content_length
          
          result.read_body {|chunk|
            callback(:progress, self, total, size += chunk.size)
            data.write(chunk)
          }
          
          data.rewind
          data
        else
          data = result.body
          format ? format.decode(data) : data
        end
      end
      
      def callbacks(type = nil)
        @callbacks ||= {}
        return @callbacks unless type
        @callbacks[type] ||= []
      end
    
      def callback(type, *args)
        procs = self.class.callbacks(type) + callbacks(type)
        procs.compact.each {|c| c.call(*args) }
      end
  end
  
  class Request
    include Callbacks
  end
end