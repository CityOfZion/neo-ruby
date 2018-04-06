# frozen_string_literal: true

module Neo
  class Script
    attr_reader :verify, :invoke

    def read(data)
      @invoke = data.read_hex
      @verify = data.read_hex
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
