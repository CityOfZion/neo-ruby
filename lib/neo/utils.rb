module Neo
  # Utility module
  module Utils
    def self.reverse_hex_string(hex)
      hex.scan(/../).reverse.join
    end

    def self.read_hex_string(io, length, reverse = false)
      hex = io.read(length).unpack('H*').first
      reverse ? reverse_hex_string(hex) : hex
    end

    def self.read_string(io)
      length = read_variable_integer(io)
      io.read(length)
    end

    def self.read_variable_integer(io)
      length = read_uint8(io)
      case length
      when 0xfd then read_uint16(io)
      when 0xfe then read_uint32(io)
      when 0xff then read_uint64(io) # TODO: Test this?
      else length
      end
    end

    def self.read_uint8(io)
      io.read(1).unpack('C').first
    end

    def self.read_uint16(io)
      io.read(2).unpack('v').first
    end

    def self.read_uint32(io)
      io.read(4).unpack('V').first
    end

    def self.read_uint64(io)
      io.read(8).unpack('Q<').first
    end

    # TODO: Do better than this?
    def read_fixed8(io)
      read_uint64(io) / 100000000.0
    end

    # Provides Base58 encoding/decoding
    module Base58
      ALPHABET = %w[
        1 2 3 4 5 6 7 8 9
        A B C D E F G H J
        K L M N P Q R S T
        U V W X Y Z a b c
        d e f g h i j k m
        n o p q r s t u v
        w x y z
      ].freeze

      BASE = ALPHABET.length

      def self.encode(n)
        return ALPHABET[0] if n.zero?
        buffer = ''
        while n > 0
          remainder = n % BASE
          n /= BASE
          buffer = ALPHABET[remainder] + buffer
        end
        buffer
      end

      def self.decode(string)
        n = 0
        power = string.length - 1
        string.each_char do |c|
          position = ALPHABET.index(c)
          raise InvalidCharacterError if position.nil?
          n += position * (BASE**power)
          power -= 1
        end
        n
      end

      class InvalidCharacterError < RuntimeError; end
    end
  end
end
