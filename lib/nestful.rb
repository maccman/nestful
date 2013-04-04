require 'nestful/version'
require 'nestful/exceptions'

module Nestful
  autoload :Endpoint,   'nestful/endpoint'
  autoload :Formats,    'nestful/formats'
  autoload :Connection, 'nestful/connection'
  autoload :Helpers,    'nestful/helpers'
  autoload :Request,    'nestful/request'
  autoload :Response,   'nestful/response'
  autoload :Resource,   'nestful/resource'

  extend self

  def get(url, *args)
    Endpoint[url].get(*args)
  end

  def post(url, options = {})
    Endpoint[url].post(*args)
  end

  def put(url, options = {})
    Endpoint[url].put(*args)
  end

  def delete(url, options = {})
    Endpoint[url].delete(*args)
  end
end