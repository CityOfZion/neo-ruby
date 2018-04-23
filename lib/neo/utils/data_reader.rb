# frozen_string_literal: true

module Neo
  module Utils
    # Utility class for reading serialized data
    class DataReader
      attr_reader :io

      def initialize(data, hex = true)
        @io = data_to_readable(data, hex)
      end

      def read_uint8
        read 1, 'C'
      end

      alias read_byte read_uint8

      def read_uint16
        read 2, 'v'
      end

      def read_uint32
        read 4, 'V'
      end

      def read_uint64
        read 8, 'Q<'
      end

      def read_bool
        !read_byte.zero?
      end

      def read_vint
        length = read_byte
        case length
        when 0xfd then read_uint16
        when 0xfe then read_uint32
        when 0xff then read_uint64
        else length
        end
      end

      def read_string
        @io.read read_vint
      end

      def read_hex(length = nil, reverse = false)
        hex = read length || read_vint, 'H*'
        reverse ? Utils.reverse_hex_string(hex) : hex
      end

      def read_fixed8
        read_uint64 / 100_000_000.0
      end

      def read_time
        Time.at read_uint32
      end

      def read(size, format)
        @io.read(size).unpack(format).first
      end

      def inspect
        @io.string.unpack('H*').first
      end

      def move_to(position)
        @io.seek(position, IO::SEEK_SET)
      end

      private

      def data_to_readable(data, hex)
        return data if data.respond_to? :read
        StringIO.new hex ? [data].pack('H*') : data
      end
    end
  end
end
