require 'cgi'

module Nestful
  module Helpers extend self
    def to_param(value, key = nil)
      case value
      when Hash  then value.map { |k,v| to_param(v, append_key(key,k)) }.join('&')
      when Array then value.map { |v| to_param(v, "#{key}[]") }.join('&')
      when nil   then ''
      else
        "#{key}=#{CGI.escape(value.to_s)}"
      end
    end

    def camelize(value)
      value.to_s.split('_').map {|w| w.capitalize }.join
    end

    protected

    def append_key(root_key, key)
      root_key.nil? ? key : "#{root_key}[#{key.to_s}]"
    end
  end
end