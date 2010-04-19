Nestful is a simple Ruby HTTP/REST client with a sane API. 

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

  * headers
  * params
  * buffer
  * method

Connection options:

  * proxy
  * user
  * password
  * auth_type
  * timeout
  * ssl_options

## API
  
### GET request

    Nestful.get 'http://example.com'

### POST request

    Nestful.post 'http://example.com', :format => :form

### JSON request

    Nestful.get 'http://example.com', :format => :json
    Nestful.post 'http://example.com', :format => :json, :params => {:q => 'test'}
  
### Resource

    Nestful::Resource.new('http://example.com')['assets'].get(:format => :xml)

### Buffer download, return Tempfile

    Nestful.get 'http://example.com/file.jpg', :buffer => true

### Callbacks

    Nestful.get 'http://www.google.co.uk', :buffer => true, :progress => Proc.new {|conn, total, size| p total; p size }
    Nestful::Request.before_request {|conn| }
    Nestful::Request.after_request {|conn, response| }

### Multipart post

    Nestful.post 'http://example.com', :format => :multipart, :params => {:file => File.open('README')}

## Credits
  Large parts of the connection code were taken from ActiveResource