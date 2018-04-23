# frozen_string_literal: true

module Neo
  module Utils
    # Utility class for writing serialized data
    class DataWriter
      attr_reader :io

      def initialize
        @io = StringIO.new
      end

      def write_uint8(value)
        write value, 'C'
      end

      alias write_byte write_uint8

      def write_uint16(value)
        write value, 'v'
      end

      def write_uint32(value)
        write value, 'V'
      end

      def write_uint64(value)
        write value, 'Q<'
      end

      def write_bool(value)
        write_byte value ? 1 : 0
      end

      def write_vint(value)
        case value
        when 0...0xfc then @io.write [value].pack('C')
        when 0xfd...0xffff then @io.write [0xfd, value].pack('Cv')
        when 0x1000000...0xffffffff then @io.write [0xfe, value].pack('CV')
        when 0x100000000...0xffffffffffffffff then @io.write [0xff, value].pack('CQ')
        else
          raise 'Too Large' # TODO: Raise a better error?
        end
      end

      def write_string(value)
        write_vint value.length
        @io.write [value].pack("a#{value.length}")
      end

      def write_hex(value, fixed_length = false, reverse = false)
        hex = Utils.strip_hex_prefix(value)
        write_vint hex.length unless fixed_length
        write reverse ? Utils.reverse_hex_string(hex) : hex, 'H*'
      end

      def write_time(value)
        write_uint32 value.to_i
      end

      def write(value, format)
        @io.write [value].pack(format)
      end

      def inspect
        @io.string.unpack('H*').first
      end
    end
  end
end
