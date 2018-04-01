# frozen_string_literal: true

module Neo
  module VM
    # An execution context
    class Context
      attr_reader :script, :push_only
      attr_accessor :instruction_pointer

      def initialize(script, push_only: false)
        @script = script
        @push_only = push_only
        @instruction_pointer = 0
      end

      def script_hash
        script.hash
      end

      def read_byte
        byte = script.bytes[@instruction_pointer]
        @instruction_pointer += 1
        byte
      end

      def read_bytes(n)
        bytes = []
        n.times { bytes << read_byte }
        ByteArray.new(bytes)
      end

      def next_instruction
        return :RET if @instruction_pointer >= script.length
        VM::OpCode[read_byte]
      end

      def clone
        context = Context.new script, push_only: push_only
        context.instruction_pointer = instruction_pointer
        context
      end
    end
  end
end
