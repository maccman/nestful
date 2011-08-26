require 'yaml'
require 'active_support/json'

module Nestful
  module Formats
    class JsonFormat < Format
      def extension
        'json'
      end

      def mime_type
        'application/json'
      end

      def encode(hash, options = nil)
        ActiveSupport::JSON.encode(hash, options)
      end

      def decode(json)
        ActiveSupport::JSON.decode(json)
      end
    end
  end
end
