require 'cgi'

module Nestful
  module Helpers extend self
    def to_param(object, namespace = nil)
      case object
      when Hash
        object.map do |key, value|
          key = "#{namespace}[#{key}]" if namespace
          "#{CGI.escape(to_param(key))}=#{CGI.escape(to_param(value, key))}"
        end.join('&')

      when Array
        object.each do |value|
          to_param(value)
        end.join('/')

      else
        object.to_s
      end
    end

    def camelize(value)
      value.to_s.split('_').map {|w| w.capitalize }.join
    end
  end
end