module Neo
  # Utility module
  module Utils
    def self.bin_to_hex(bin)
      bin.unpack('H*').first.scan(/../).reverse.join
    end

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
        return ALPHABET[0] if n == 0
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
