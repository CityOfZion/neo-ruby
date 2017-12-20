module Neo
  # Represents a block in the Neo blockchain
  class Block
    attr_reader :data,
                :version,
                :previous_block_hash,
                :merkle_root,
                :time_stamp,
                :height,
                :nonce,
                :next_consensus,
                :script,
                :transactions

    alias consensus_data nonce

    # Construct a new block from given data
    # @param data [Hash] Ruby hash of parsed JSON format block data
    def initialize(data = nil)
      @data = StringIO.new [data].pack('H*')
      @transactions = []
      parse_header
    end

    def parse_header
      @version = Utils.read_uint32(data)
      @previous_block_hash = Utils.read_hex_string(data, 32, true)
      @merkle_root = Utils.read_hex_string(data, 32, true)
      @time_stamp = Utils.read_uint32(data)
      @height = Utils.read_uint32(data)
      @nonce = Utils.read_hex_string(data, 8, true)
      @next_consensus = Key.script_hash_to_address(Utils.read_hex_string(data, 20))
      data.read(1)
      @script = Script.read(data)
      transaction_count = Utils.read_variable_integer(data)
      transaction_count.times do
        @transactions << Transaction.read(data)
      end
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
        data = Neo.rpc 'getblock', identifier
        Block.new data
      end
    end
  end
end
