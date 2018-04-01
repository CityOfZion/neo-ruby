# frozen_string_literal: true

module Neo
  module SDK
    # Script Builder
    class Builder
      attr_reader :operations, :addr_index

      def initialize
        @operations = []
        @addr_index = 0
      end

      def bytes
        ByteArray.new @operations.map(&:bytes).flatten
      end

      def emit(op_code, param = nil)
        operation = Operation.new(op_code, addr_index, param)
        @operations << operation
        @addr_index += operation.length
        operation
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def emit_push(data)
        case data
        when true      then emit :PUSHT
        when false     then emit :PUSHF
        when -1        then emit :PUSHM1
        when 0..16     then emit "PUSH#{data}".to_sym
        when Array     then emit_push_array data
        when ByteArray then emit_push_bytes data
        when Integer   then emit_push_bytes ByteArray.from_integer(data)
        when String    then emit_push_bytes ByteArray.from_string(data.encode('UTF-8'))
        # :nocov:
        else raise NotImplementedError, data
        end
        # :nocov:
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def emit_app_call(script_hash, params: [], use_tail_call: false)
        params.reverse.each do |param|
          emit_push param
        end
        emit use_tail_call ? :TAILCALL : :APPCALL, ByteArray.from_hex_string(script_hash)
      end

      def emit_push_array(items)
        items.reverse.each do |item|
          emit_push item
        end
        emit_push items.length
        emit :PACK
      end

      def emit_push_bytes(byte_array)
        len = byte_array.length
        case len
        when 1..75 then emit "PUSHBYTES#{len}", byte_array
        # :nocov:
        else raise NotImplementedError, len
        end
        # :nocov:
      end
    end
  end
end
