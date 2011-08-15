Nestful is a simple Ruby HTTP/REST client with a sane API. 

## Installation

    sudo gem install nestful

## Features

  * Simple API
  * File buffering
  * Before/Progress/After Callbacks
  * JSON & XML requests
  * Multipart requests (file uploading)
  * Resource API
  * Proxy support
  * SSL support

## Options

Request options:

  * headers (hash)
  * params  (hash)
  * buffer  (true/false)
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

    Nestful.post 'http://example.com', :format => :form #=> "body"

other supported mime-type formats are :json, :multipart, :xml

### Parameters

    Nestful.get 'http://example.com', :params => {:nestled => {:params => 1}}

### JSON request

    Nestful.get 'http://example.com', :format => :json  #=> {:json_hash => 1}
    Nestful.json_get 'http://example.com'               #=> {:json_hash => 1}
    Nestful.post 'http://example.com', :format => :json, :params => {:q => 'test'} #=> {:json_hash => 1}
  
### Resource

The Resource class provides a single object to work with restful services. The following example does a GET request to the URL; http://example.com/assets/1/

    Nestful::Resource.new('http://example.com')['assets'][1].get(:format => :xml) #=> {:xml_hash => 1}

The Resource class also supports, post, json_post and json_get methods.

### Buffer download, return Tempfile

    Nestful.get 'http://example.com/file.jpg', :buffer => true #=> <File ...>

### Callbacks

    Nestful.get 'http://www.google.co.uk', :buffer => true, :progress => Proc.new {|conn, total, size| p total; p size }
    Nestful::Request.before_request {|conn| }
    Nestful::Request.after_request {|conn, response| }

### Multipart post

    Nestful.post 'http://example.com', :format => :multipart, :params => {:file => File.open('README')}
    
### OAuth

Nestful uses ROAuth for OAuth support - check out supported options: http://github.com/maccman/roauth
    
    require 'nestful/oauth'
    Nestful.get 'http://example.com', :oauth => {}

## Credits
  Large parts of the connection code were taken from ActiveResource
