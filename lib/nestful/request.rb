module Nestful
  class Request
    attr_reader :options, :format, :url
    attr_accessor :params, :body, :method, :headers

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
      self.format  ||= :form
    end

    def format=(mime_or_format)
      @format = mime_or_format.is_a?(Symbol) ?
        Formats[mime_or_format].new : mime_or_format
    end

    def url=(value)
      @url = value
      @uri = nil
      @url
    end

    def uri
      return @uri if @uri

      url = @url.match(/\Ahttps?:\/\//) ? @url : "http://#{@url}"

      @uri = URI.parse(url)
      @uri.path = '/' if @uri.path.empty?

      if @uri.query
        @params.merge!(Helpers.from_param(@uri.query))
        @uri.query = nil
      end

      @uri
    end

    def path
      uri.path
    end

    def execute
      if encoded?
        result = connection.send(method, path, encoded, build_headers)
      else
        result = connection.send(method, query_path, build_headers)
      end

      Response.new(result)

    rescue Redirection => error
      self.url = error.response['Location']
      execute
    end

    protected

    def connection
      Connection.new(uri,
        :proxy       => proxy,
        :timeout     => timeout,
        :ssl_options => ssl_options
      )
    end

    def content_type_headers
      if encoded?
        {'Content-Type' => format.mime_type}
      else
        {}
      end
    end

    def auth_headers
      if auth_type == :bearer
        { 'Authorization' => "Bearer #{@password}" }
      elsif auth_type == :basic
        { 'Authorization' => 'Basic ' + ["#{@user}:#{@password}"].pack('m').delete("\r\n") }
      else
        { }
      end
    end

    def build_headers
      auth_headers
        .merge(content_type_headers)
        .merge(headers)
    end

    def query_path
      query_path = path

      if params.any?
        query_path += '?' + Helpers.to_param(params)
      end

      query_path
    end

    def encoded?
      [:post, :put].include?(method)
    end

    def encoded
      params.any? ? format.encode(params) : body
    end
  end
end