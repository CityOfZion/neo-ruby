module Neo
  # Represents a block in the Neo blockchain
  class Block
    attr_reader :data

    # Construct a new block from given data
    # @param data [Hash] Ruby hash of parsed JSON format block data
    def initialize(data = {})
      @data = data
    end

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

      # Returns the corresponding block information according to the specified hash or index
      #
      # @param identifier [Integer, String] hash value or index of block to get
      # @return [Neo::Block]
      def get(identifier)
        data = Neo.rpc 'getblock', identifier, 1
        Block.new data
      end
    end
  end
end
