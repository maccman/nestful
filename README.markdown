Nestful is a simple Ruby HTTP/REST client with a sane API.

## Installation

    sudo gem install nestful

## Features

  * Simple API
  * File buffering
  * Before/Progress/After Callbacks
  * JSON requests
  * Multipart requests (file uploading)
  * Resource API
  * Proxy support
  * SSL support

## Request Options

Request options:

  * headers (hash)
  * params  (hash)
  * method  (:get/:post/:put/:delete/:head)

Connection options:

  * proxy
  * user
  * password
  * auth_type
  * timeout
  * ssl_options

## API

### GET request

    Nestful.get 'http://example.com' #=> "body"

### POST request

    Nestful.post 'http://example.com', :params => {:foo => 'bar'}
    Nestful.post 'http://example.com', :params => {:foo => 'bar'}, :format => :json

### Parameters

    Nestful.get 'http://example.com', :params => {:nestled => {:params => 1}}

### Endpoint

The `Endpoint` class provides a single object to work with restful services. The following example does a GET request to the URL; http://example.com/assets/1/

    Nestful::Endpoint.new('http://example.com')['assets'][1].get

### Multipart post

    Nestful.post 'http://example.com', :format => :multipart, :params => {:file => File.open('README')}

## Credits

Large parts of the connection code were taken from ActiveResource
