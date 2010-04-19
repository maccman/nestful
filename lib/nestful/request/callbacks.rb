module Nestful
  class Request
    module Callbacks
      CALLBACKS = [
        :before_request, 
        :after_request, 
        :progress
      ]
      
      def self.included(base)
        CALLBACKS.each do |callback|
          base.instance_eval(<<-EOS, __FILE__, __LINE__ + 1)
            def #{callback}(method = nil, &block)
              callbacks(:#{callback}) << (method||block)
            end
          EOS
        
          base.class_eval(<<-EOS, __FILE__, __LINE__ + 1)
            def #{callback}(method = nil, &block)
              callbacks(:#{callback}) << (method||block)
            end
            alias_method :#{callback}=, :#{callback}
          EOS
        end
      end
    end
  end
end