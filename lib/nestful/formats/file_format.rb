require "active_resource/secure_random"

module Nestful
  module Formats
    module FileFormat
      extend self
      EOL = "\r\n"

      def extension
      end

      def mime_type
        %Q{multipart/form-data; boundary="#{boundary}"}
      end

      def encode(params, options = nil)
        stream   = Tempfile.new("nf.#{rand(1000)}")
        stream.write("--#{boundary}")
        stream.write(EOL)
        params.each do |key, value|
          if value.is_a?(File) || value.is_a?(StringIO)
            create_file_field(stream, key, value)
          else
            create_field(stream, key, value)
          end
        end
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
          stream.write(%Q{Content-Disposition: form-data; name="#{key}"; filename="#{filename(value)}"})
          stream.write(EOL)
          stream.write(EOL)
          while data = value.read(8124)
            stream.write(data)
          end
        end
    
        def create_field(stream, key, value)
          stream.write(%Q{Content-Disposition: form-data; name="#{key}"})
          stream.write(EOL)
          stream.write(EOL)
          stream.write(value)
        end
  
        def filename(body)
          return body.original_filename   if body.respond_to?(:original_filename)
          return File.basename(body.path) if body.respond_to?(:path)
          "Unknown"
        end
    end
  end
end