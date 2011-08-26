module Nestful	
  module Formats
    class BlankFormat < Format
      def encode(params, options = nil)
        raise 'Choose an encoding format, such as :form'	
      end

      def decode(body)
        body
      end
    end	
  end  	
end