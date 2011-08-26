require 'roauth'

module Nestful
  class Request
    attr_accessor :oauth
    
    def oauth_sign
      return unless oauth
      params = method == :get ? self.params : {}

      signature = ROAuth.header(
        oauth, 
        uri.to_s, 
        params, 
        method
      )
    
      self.headers ||= {}
      self.headers['Authorization'] = signature
    end

    before_request(&:oauth_sign)
  end
end