module Nestful
  module Formats
    module BlankFormat
      extend self

      def extension
      end
  
      def mime_type
      end
  
      def encode(params, options = nil)
        raise "Choose an encoding format, such as :form"
      end
  
      def decode(body)
        body
      end
    end
  end
end