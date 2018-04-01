# frozen_string_literal: true

require 'neo/vm/op_code'
require 'digest'

module Neo
  module SDK
    # AVM Script parser
    class Script
      @table = {}
      attr_reader :bytes, :return_type, :param_types, :source
      attr_accessor :position

      def initialize(bytes = [], source = nil, return_type = nil, param_types = [])
        @bytes = bytes
        @return_type = return_type
        @param_types = param_types
        @source = source
        register
      end

      def hash
        sha256 = ::Digest::SHA256.digest bytes.data
        rmd160 = ::Digest::RMD160.hexdigest sha256
        rmd160.scan(/../).reverse.join
      end

      def length
        bytes.length
      end

      def register
        Script.table[hash] = self
      end

      class << self
        attr_reader :table
      end

      # Dump a script for debugging purposes
      class Dump
        attr_reader :context

        def initialize(script)
          @context = VM::Context.new(script)
          @operations = []
          parse
        end

        def parse
          position = 0
          while (op = context.next_instruction)
            if respond_to? op
              send op, position
            else
              @operations << Operation.new(op, position)
            end
            position = context.instruction_pointer
            return if position >= context.script.length
          end
        end

        def operation_details
          @operations.map(&:details)
        end

        # rubocop:disable Naming/MethodName

        (0x01..0x4B).each do |n|
          name = "PUSHBYTES#{n}".to_sym
          define_method name do |pos|
            @operations << Operation.new(name, pos, context.read_bytes(n))
          end
        end

        def PUSHDATA1(pos)
          @operations << Operation.new(__callee__, pos, context.read_bytes(context.read_byte))
        end

        alias SYSCALL PUSHDATA1

        def PUSHDATA2(pos)
          @operations << Operation.new(__callee__, pos, context.read_bytes(2))
        end

        alias CALL PUSHDATA2
        alias JMP PUSHDATA2
        alias JMPIF PUSHDATA2
        alias JMPIFNOT PUSHDATA2

        def PUSHDATA4(pos)
          @operations << Operation.new(__callee__, pos, context.read_bytes(4))
        end

        def APPCALL(pos)
          @operations << Operation.new(__callee__, pos, context.read_bytes(20))
        end

        alias TAILCALL APPCALL

        # rubocop:enable Naming/MethodName

        # Represents an op code and an optional accompanying parameter.
        class Operation
          attr_reader :name
          attr_reader :position
          attr_reader :param

          def initialize(name, position, param = nil)
            @name = name
            @position = position
            @param = param
          end

          def details
            message = [name]
            message << param if param
            [
              position.to_s.rjust(4, '0'),
              VM::OpCode.const_get(name).to_s(16).rjust(2, '0'),
              *message
            ]
          end
        end
      end
    end
  end
end
