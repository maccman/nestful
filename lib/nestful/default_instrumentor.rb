module Nestful
  class DefaultInstrumentor
    def self.instrument(_name, _payload)
      yield if block_given?
    end
  end
end
