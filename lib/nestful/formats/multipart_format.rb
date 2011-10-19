require 'securerandom'

module Nestful
  module Formats
    class MultipartFormat < Format
      EOL = "\r\n"
      
      attr_reader :boundary, :stream
      
      def initialize(*args)
        super
        @boundary = SecureRandom.hex(10)
        @stream   = Tempfile.new("nf.#{rand(1000)}")
        @stream.binmode
      end

      def mime_type
        %Q{multipart/form-data; boundary=#{boundary}}
      end

      def encode(params, options = nil)
        to_multipart(params)
        stream.write("--" + boundary + "--" + EOL)
        stream.flush
        stream.rewind
        stream
      end

      def decode(body)
        body
      end
  
      protected
        def to_multipart(params, namespace = nil)
          params.each do |key, value|
            key = namespace ? "#{namespace}[#{key}]" : key

            # Support nestled params
            if value.is_a?(Hash)
              to_multipart(value, key)
              next
            end

            stream.write("--" + boundary + EOL)

            if value.is_a?(File) || value.is_a?(StringIO) || value.is_a?(Tempfile)
              create_file_field(key, value)
            else
              create_field(key, value)
            end
          end          
        end
      
        def create_file_field(key, value)
          stream.write(%Q{Content-Disposition: form-data; name="#{key}"; filename="#{filename(value)}"} + EOL)
          stream.write(%Q{Content-Type: application/octet-stream} + EOL)
          stream.write(%Q{Content-Transfer-Encoding: binary} + EOL)
          stream.write(EOL)
          while data = value.read(8124)
            stream.write(data)
          end
          stream.write(EOL)
        end
    
        def create_field(key, value)
          stream.write(%Q{Content-Disposition: form-data; name="#{key}"} + EOL)
          stream.write(EOL)
          stream.write(value)
          stream.write(EOL)
        end
  
        def filename(body)
          return body.original_filename   if body.respond_to?(:original_filename)
          return File.basename(body.path) if body.respond_to?(:path)
          'Unknown'
        end
    end
  end
end
