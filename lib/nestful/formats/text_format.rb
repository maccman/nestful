module Nestful
  module Formats
    class TextFormat < Format
      def mime_type
        'text/plain'
      end

      def encode(body)
         body
      end

      def decode(body)
        body
      end
    end
  end
end
