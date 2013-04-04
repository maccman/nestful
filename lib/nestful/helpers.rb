require 'cgi'

module Nestful
  module Helpers extend self
    def to_query(key, value)
      case key
      when Hash
        "#{CGI.escape(to_param(key))}=#{CGI.escape(to_param(value))}"

      when Array
        prefix = "#{key}[]"
        value.collect { |v| to_query(prefix, v) }.join('&')

      else
        value
      end
    end

    def to_param(object, namespace = nil)
      case object
      when Hash
        object.map do |key, value|
          key = "#{namespace}[#{key}]" if namespace
          to_query(key, value)
        end.join('&')

      when Array
        object.each do |value|
          to_param(value)
        end.join('/')

      else
        value
      end
    end

    def camelize(value)
      value.to_s.split('_').map {|w| w.capitalize }.join
    end
  end
end