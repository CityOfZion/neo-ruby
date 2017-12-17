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

      # Returns the hash of the tallest block in the main chain.
      #
      # @return [String]
      def best_hash
        Neo.rpc 'getbestblockhash'
      end
    end
  end
end
