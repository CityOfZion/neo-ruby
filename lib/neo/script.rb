module Neo
  class Script
    attr_reader :verify, :invoke

    def read(io)
      invoke_length = Utils.read_variable_integer(io)
      @invoke = Utils.read_hex_string(io, invoke_length)
      verify_length = Utils.read_variable_integer(io)
      @verify = Utils.read_hex_string(io, verify_length)
      self
    end

    class << self
      def read(io)
        script = Script.new
        script.read(io)
      end
    end
  end
end
