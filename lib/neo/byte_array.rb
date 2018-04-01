# frozen_string_literal: true

module Neo
  # A convenience class for working with data as byte arrays rather than strings or plain arrays
  class ByteArray
    attr_reader :data

    def initialize(data = [])
      @data = +''.encode(Encoding::ASCII_8BIT)
      bytes = data.is_a?(String) ? data.unpack('C*') : data
      bytes.each { |datum| self << datum }
    end

    def bytes
      data.bytes
    end

    def length
      bytes.length
    end

    def [](index)
      data.bytes[index]
    end

    def []=(index, byte)
      data.setbyte index, byte
    end

    def <<(byte)
      data << byte
    end

    def ==(other)
      data == VM::Helper.unwrap_byte_array(other).data
    end

    def +(other)
      ByteArray.new data.bytes + VM::Helper.unwrap_byte_array(other).data.bytes
    end

    def skip(count)
      ByteArray.new bytes.drop(count)
    end

    def take(count)
      ByteArray.new bytes.take(count)
    end

    def to_string
      data.unpack('U*').pack('U*')
    end

    def to_hex_string(prefix: false)
      hex = data.unpack('H*').first
      prefix ? '0x' + hex : hex
    end

    def to_int16
      data.unpack('s').first
    end

    def to_uint16
      data.unpack('S').first
    end

    def to_int32
      data.unpack('l').first
    end

    def to_uint32
      data.unpack('L').first
    end

    def to_integer
      to_hex_string.scan(/../).reverse.join.hex
    end

    def to_s
      "<#{bytes[0...8].map { |b| b.to_s(16).rjust(2, '0') }.join(' ')}>"
    end

    alias inspect to_s

    class << self
      def from_string(string)
        new string.unpack('C*')
      end

      def from_hex_string(hex)
        new [hex].pack('H*')
      end

      def from_integer(num)
        hex = num.to_s 16
        hex = '0' + hex if hex.length.odd?
        from_hex_string hex.scan(/../).reverse.join
      end

      def from_int16(num)
        Neo::ByteArray.from_string [num].pack('s')
      end
    end
  end
end
