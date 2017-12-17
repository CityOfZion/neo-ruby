module Neo
  # Represents a block in the Neo blockchain
  class Block
    class << self
      # Gets the number of blocks in the main chain.
      #
      # @return [Numeric]
      def height
        Neo.rpc 'getblockcount'
      end
    end
  end
end
