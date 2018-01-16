module Neo
  class Script
    attr_reader :verify, :invoke

    def initialize(invoke = nil, verify = nil)
      @invoke = invoke
      @verify = verify
    end

    class << self
      def read(io)
        new(io.read_hex, io.read_hex)
      end
    end
  end
end
