module Nestful
  class Request
    def self.callbacks(type = nil) #:nodoc:
      @callbacks ||= {}
      return @callbacks unless type
      @callbacks[type] ||= []
    end
    
    attr_reader :options, :format, :url
    attr_accessor :params, :body, :buffer, :method, :headers, :callbacks, :raw, :extension
    
    # Connection options
    attr_accessor :proxy, :user, :password, :auth_type, :timeout, :ssl_options
  
    def initialize(url, options = {})
      @url     = url.to_s
      
      @options = options
      @options.each do |key, val| 
        method = "#{key}="
        send(method, val) if respond_to?(method)
      end

      self.method  ||= :get
      self.params  ||= {}
      self.headers ||= {}
      self.body    ||= ''
      self.format  ||= :blank
    end
    
    def format=(mime_or_format)
      @format = mime_or_format.is_a?(Symbol) ?
        Formats[mime_or_format].new : mime_or_format
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
    
    def url=(value)
      @url = value
      @uri = nil
      @url
    end
        
    def uri
      return @uri if @uri
      
      url = @url.match(/^http/) ? @url : "http://#{@url}"
      
      @uri = URI.parse(url)
      @uri.path = "/" if @uri.path.empty?
      
      if extension
        extension = format.extension if extension.is_a?(Boolean)
        @uri.path += ".#{extension}"
      end
      
      @uri.query.split("&").each do |res|
        key, value = res.split("=")
        @params[key] = value
      end if @uri.query
      
      @uri
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
        connection.send(method, path, encoded, headers) do |res| 
          result = decoded(res)
          result.class_eval { attr_accessor :response }
          result.response = res
        end
      else
        connection.send(method, query_path, headers) do |res|
          result = decoded(res) 
          result.class_eval { attr_accessor :response }
          result.response = res
        end
      end
      callback(:after_request, self, result)
      result
    rescue Redirection => error
      self.url = error.response['Location']
      execute
    end
            
    protected
      def encoded
        params.any? ? format.encode(params) : body
      end

      def decoded(result)
        if buffer
          data  = Tempfile.new("nfr.#{rand(1000)}")
          size  = 0
          total = result.content_length
          
          result.read_body do |chunk|
            callback(:progress, self, total, size += chunk.size)
            data.write(chunk)
          end
          
          data.rewind
          data
        else
          return result if raw
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
