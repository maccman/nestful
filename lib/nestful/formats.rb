module Nestful
  module Formats
    class Format
      def extension
      end

      def mime_type
      end
      
      def encode(*args)
      end
      
      def decode(*args)
      end
    end
    
    autoload :BlankFormat,      'nestful/formats/blank_format'
    autoload :TextFormat,       'nestful/formats/text_format'
    autoload :MultipartFormat,  'nestful/formats/multipart_format'
    autoload :FormFormat,       'nestful/formats/form_format'
    autoload :XmlFormat,        'nestful/formats/xml_format'
    autoload :JsonFormat,       'nestful/formats/json_format'
    
    # Lookup the format class from a mime type reference symbol. Example:
    #
    #   Nestful::Formats[:xml]  # => Nestful::Formats::XmlFormat
    #   Nestful::Formats[:json] # => Nestful::Formats::JsonFormat
    def self.[](mime_type_reference)
      Nestful::Formats.const_get(ActiveSupport::Inflector.camelize(mime_type_reference.to_s) + "Format")
    end
  end  
end
