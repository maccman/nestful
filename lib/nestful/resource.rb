require 'uri'

module Nestful
  class Resource
    def self.endpoint(value = nil)
      @endpoint = value if value
      return @endpoint if @endpoint
      defined?(super) ? super : nil
    end

    def self.url(value = nil)
      @url = value if value
      @url ? URI.join(endpoint || '', @url) : raise('Must define url')
    end

    def self.options(value = nil)
      @options = value if value
      @options
    end

    def self.get(url, params = {}, options = {})
      request(url, options.merge(:method => :get, :params => params))
    end

    def self.put(url, params = {}, options = {})
      request(url, options.merge(:method => :put, :params => params))
    end

    def self.post(url, params = {}, options = {})
      request(url, options.merge(:method => :post, :params => params))
    end

    def self.delete(url, params = {}, options = {})
      request(url, options.merge(:method => :delete, :params => params))
    end

    def self.request(url, options = {})
      Request.new(url, self.options.merge(options)).execute
    end

    def self.all
      self.new(get(url))
    end

    def self.find(id)
      self.new(get(URI.join(url, id.to_s)))
    end

    def self.new(attributes = {}, options = {})
      if attributes.is_a?(Array)
        attributes.map {|set| super(set, options) }
      else
        super
      end
    end

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = {}
      load(attributes)
    end

    def get(action = '', *args)
      self.class.get(url(action), *args)
    end

    def put(action = '', *args)
      self.class.put(url(action), *args)
    end

    def post(action = '', *args)
      self.class.post(url(action), *args)
    end

    def delete(action = '', *args)
      self.class.delete(url, *args)
    end

    def url(*parts)
      URI.join(
        self.class.url,
        self.id.to_s,
        *parts.map(&:to_s)
      )
    end

    def id #:nodoc:
      self['id']
    end

    def type #:nodoc:
      self['type']
    end

    def [](key)
      attributes[key]
    end

    def []=(key,value)
      attributes[key] = value
    end

    def to_hash
      attributes.dup
    end

    alias_method :as_json, :to_hash

    def to_json(*)
      as_json.to_json
    end

    def load(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    alias_method :respond_to_without_attributes?, :respond_to?

    def respond_to?(method, include_priv = false)
      method_name = method.to_s
      if attributes.nil?
        super
      elsif method_name =~ /(?:=|\?)$/ && attributes.include?($`)
        true
      else
        super
      end
    end

    protected

    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s

      if method_name =~ /(=|\?)$/
        case $1
        when "="
          attributes[$`] = arguments.first
        when "?"
          attributes[$`]
        end
      else
        return attributes[method_name] if attributes.include?(method_name)
        super
      end
    end
  end
end