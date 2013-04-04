require 'uri'

module Nestful
  class Resource
    def self.endpoint(value = nil)
      @endpoint = value if value
      @endpoint || ''
    end

    def self.url(value = nil)
      @url = value if value
      @url ? URI.join(endpoint, @url) : raise('Must define url')
    end

    def self.options(value = nil)
      @options = value if value
      @options || {}
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

    attr_reader :attributes, :options

    def initialize(attributes = {}, options = {})
      @attributes = indifferent_attributes(attributes.to_hash)
      @options    = self.class.options.merge(options)
    end

    def get(*args)
      self.class.get(url, *args)
    end

    def put(*args)
      self.class.put(url, *args)
    end

    def post(*args)
      self.class.post(url, *args)
    end

    def delete(*args)
      self.class.delete(url, *args)
    end

    alias_method :destroy, :delete

    def url
      URI.join(self.class.url, self.id.to_s)
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
      @attributes.dup
    end

    alias_method :as_json, :to_hash

    def to_json(*)
      as_json.to_json
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

    def indifferent_attributes(attributes)
      attributes = indifferent_hash.merge(attributes)
      attributes.each do |key, value|
        next unless value.is_a?(Hash)
        attributes[key] = indifferent_attributes(value)
      end
    end

    # Creates a Hash with indifferent access.
    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end

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