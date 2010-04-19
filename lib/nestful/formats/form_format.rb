module Nestful
  module Formats
    module FormFormat
      extend self

      def extension
      end
  
      def mime_type
        "application/x-www-form-urlencoded"
      end
  
      def encode(params, options = nil)
        params.to_param
      end
  
      def decode(body)
        body
      end
    end
  end
end