module Nestful
  class Request
    attr_reader :options, :format, :url

    attr_accessor :params, :body, :method, :headers,
                  :proxy, :user, :password,
                  :auth_type, :timeout, :ssl_options,
                  :max_attempts, :follow_redirection,
                  :instrumentor

    def initialize(url, options = {})
      @url     = url.to_s
      @uri     = nil

      @options = {
        method:             :get,
        params:             {},
        headers:            {},
        format:             :form,
        max_attempts:       5,
        follow_redirection: true
      }.merge(options)

      @options.each do |key, val|
        method = "#{key}="
        send(method, val) if respond_to?(method)
      end
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

      @uri
    end

    def uri_params
      uri.query ? Helpers.from_param(uri.query) : {}
    end

    def path
      uri.path
    end

    def query_path
      query_path   = path.dup
      query_params = uri_params.dup
      query_params.merge!(params) unless encoded?

      if query_params.any?
        query_path += '?' + Helpers.to_url_param(query_params)
      end

      query_path
    end

    def encoded?
      [:post, :put].include?(method)
    end

    def encoded
      params.any? ? format.encode(params) : body
    end

    def execute
      with_redirection do
        result = instrument_request do
          if encoded?
            connection.send(method, query_path, encoded, build_headers)
          else
            connection.send(method, query_path, build_headers)
          end
        end

        response = Response.new(result, uri)
        instrument_response(response)

        response
      end
    ensure
      instrument_error($!) if $!
    end

    protected

    def instrument_request(&block)
      instrument('request.nestful', request: self, &block)
    end

    def instrument_error(error)
      if error.respond_to?(:response) && error.response
        instrument_response(error.response)
      end
      instrument('error.nestful', request: self, error: error)
    end

    def instrument_response(response)
      instrument(
        'response.nestful',
        request:  self,
        response: response,
        code:     response.code.to_i
      )
    end

    def with_redirection(&block)
      attempts = 1

      begin
        yield
      rescue Redirection => error
        raise error unless follow_redirection

        attempts += 1

        raise error unless error.response['Location']
        raise RedirectionLoop.new(self, error.response) if attempts > max_attempts

        location = error.response['Location'].scrub
        location = URI.parse(location)

        # Path is relative
        unless location.host
          location = URI.join(uri, location)
        end

        self.url = location.to_s
        retry
      end
    end

    def connection
      Connection.new(uri,
        proxy:       proxy,
        timeout:     timeout,
        ssl_options: ssl_options,
        request:     self
      )
    end

    def content_type_headers
      if encoded?
        { 'Content-Type' => format.mime_type }
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
        {}
      end
    end

    def build_headers
      auth_headers
        .merge(content_type_headers)
        .merge(headers)
    end

    def instrument(event, payload, &block)
      payload.merge!(
        domain: uri.host,
        method: method,
        path:   query_path
      )

      @instrumentor ||= Nestful::DefaultInstrumentor
      @instrumentor.instrument(event, payload, &block)
    end
  end
end
