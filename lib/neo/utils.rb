# frozen_string_literal: true

require 'neo/utils/data_reader'
require 'neo/utils/data_writer'

module Neo
  # Utility module
  module Utils
    autoload :VarInt, 'neo/utils/var_int'

    def self.reverse_hex_string(hex)
      hex.scan(/../).reverse.join
    end

    def self.strip_hex_prefix(hex)
      hex.sub(/^0x/, '')
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

      def self.encode(num)
        return ALPHABET[0] if num.zero?
        buffer = ''
        while num.positive?
          remainder = num % BASE
          num /= BASE
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
