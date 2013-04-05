Nestful is a simple Ruby HTTP/REST client with a sane API.

## Installation

    sudo gem install nestful

## Features

  * Simple API
  * JSON requests
  * Resource API
  * Proxy support
  * SSL support

## API

### GET request

    Nestful.get 'http://example.com' #=> "body"

### POST request

    Nestful.post 'http://example.com', :foo => 'bar'
    Nestful.post 'http://example.com', {:foo => 'bar'}, :format => :json

### Parameters

    Nestful.get 'http://example.com', :nestled => {:vars => 1}

## Request

`Request` is the base class for making HTTP requests - everthing else is just an abstraction upon it.

    Request.new(url, options = {})

Valid `Request` options are:

  * headers (hash)
  * params  (hash)
  * method  (:get/:post/:put/:delete/:head)
  * proxy
  * user
  * password
  * auth_type (:basic/:bearer)
  * timeout
  * ssl_options

## Endpoint

The `Endpoint` class provides a single object to work with restful services. The following example does a GET request to the URL; http://example.com/assets/1/

    Nestful::Endpoint.new('http://example.com')['assets'][1].get

## Resource

If you're building a binding for a REST API, then you should consider using the `Resource` class.

    class Charge < Nestful::Resource
      url 'https://api.stripe.com/v1/charges'

      def self.all
        self.new(get)
      end

      def self.find(id)
        self.new(get(id))
      end

      def refund
        post(:refund)
      end
    end

## Credits

Parts of the connection code were taken from ActiveResource
