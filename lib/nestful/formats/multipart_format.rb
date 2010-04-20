require "active_support/secure_random"

module Nestful
  module Formats
    module MultipartFormat
      extend self
      EOL = "\r\n"

      def extension
      end

      def mime_type
        %Q{multipart/form-data; boundary=#{boundary}}
      end

      def encode(params, options = nil)
        stream   = Tempfile.new("nf.#{rand(1000)}")
        params.each do |key, value|
          stream.write("--" + boundary + EOL)
          if value.is_a?(File) || value.is_a?(StringIO)
            create_file_field(stream, key, value)
          else
            create_field(stream, key, value)
          end
        end
        stream.write(EOL + "--" + boundary + "--" + EOL)
        clear_boundary
        stream.rewind
        stream
      end

      def decode(body)
        body
      end
  
      protected
        def boundary
          @boundary ||= ActiveSupport::SecureRandom.hex(10)
        end
    
        def clear_boundary
          @boundary = nil
        end
  
        def create_file_field(stream, key, value)
          stream.write(%Q{Content-Disposition: form-data; name="#{key}"; filename="#{filename(value)}"} + EOL)
          stream.write(%Q{Content-Type: application/octet-stream} + EOL)
          stream.write(%Q{Content-Transfer-Encoding: binary} + EOL)
          stream.write(EOL)
          while data = value.read(8124)
            stream.write(data)
          end
          stream.write(EOL)
        end
    
        def create_field(stream, key, value)
          stream.write(%Q{Content-Disposition: form-data; name="#{key}"} + EOL)
          stream.write(EOL)
          stream.write(value)
          stream.write(EOL)
        end
  
        def filename(body)
          return body.original_filename   if body.respond_to?(:original_filename)
          return File.basename(body.path) if body.respond_to?(:path)
          "Unknown"
        end
    end
  end
end