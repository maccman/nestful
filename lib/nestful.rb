require 'net/http'
require 'uri'
require 'tempfile'

require 'active_support/core_ext'
require 'active_support/inflector'

$:.unshift(File.dirname(__FILE__))

require 'nestful/exceptions'
require 'nestful/formats'
require 'nestful/connection'
require 'nestful/request/callbacks'
require 'nestful/request'
require 'nestful/resource'

module Nestful
  extend self

  def get(url, options = {})
    Request.new(url, ({:method => :get}).merge(options)).execute
  end
    
  def post(url, options = {})
    Request.new(url, ({:method => :post, :format => :form}).merge(options)).execute
  end
  
  def put(url, options = {})
    Request.new(url, ({:method => :put}).merge(options)).execute
  end
  
  def delete(url, options = {})
    Request.new(url, ({:method => :delete}).merge(options)).execute
  end
  
  def json_get(url, params = nil)
    get(url, :format => :json, :params => params)
  end
  
  def json_post(url, params = nil)
    post(url, :format => :json, :params => params)
  end
end