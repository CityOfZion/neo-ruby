# frozen_string_literal: true

module Neo
  module SDK
    # Intermediate Representation of a VM Opcode
    class Operation
      attr_accessor :name, :address, :data, :scope

      def initialize(name, address, data = nil)
        @name = name
        @address = address
        @data = data
        @scope = nil
      end

      # :nocov:
      def to_s
        ['%02d '.format(address), name, data ? " <#{data}>" : nil].join
      end
      # :nocov:

      def length
        bytes.length
      end

      def bytes
        @bytes = [VM::OpCode.const_get(name)]
        case data
        when ByteArray
          data.bytes.each do |byte|
            @bytes << byte
          end
        when String
          bytes_data_string(@bytes)
        when Symbol, Operation
          @bytes << 0x00
          @bytes << 0x00
        # :nocov:
        else raise NotImplementedError, data unless data.nil?
        end
        # :nocov:
        @bytes
      end

      def update(name: nil, data: nil)
        @name = name if name
        @data = data if data
      end

      private

      # Pushes self.data string to a buffer
      def bytes_data_string(bytes_buf)
        bytes_buf << Neo::Utils::VarInt.encode(data.length)
        byte_string = ByteArray.new [data].pack("a#{data.length}")
        byte_string.bytes.each do |byte|
          bytes_buf << byte
        end
      end
    end
  end
end
