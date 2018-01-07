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
      @data = Utils::DataReader.new(data)
      @transactions = []
      parse_header
    end

    def parse_header
      @version = data.read_uint32
      @previous_block_hash = data.read_hex 32, true
      @merkle_root = data.read_hex 32, true
      @time_stamp = data.read_uint32
      @height = data.read_uint32
      @nonce = data.read_hex 8, true
      @next_consensus = Key.script_hash_to_address data.read_hex(20)
      data.read_byte
      @script = Script.read data
      transaction_count = data.read_vint
      transaction_count.times do
        @transactions << Transaction.read(data)
      end
    end

    class << self
      # Gets the number of blocks in the main chain.
      #
      # @return [Numeric]
      def height
        RemoteNode.rpc 'getblockcount'
      end

      # Returns the hash of the tallest block in the main chain.
      #
      # @return [String]
      def best_hash
        RemoteNode.rpc 'getbestblockhash'
      end

      # Returns the corresponding block information according to the specified hash or index
      #
      # @param identifier [Integer, String] hash value or index of block to get
      # @return [Neo::Block]
      def get(identifier)
        data = RemoteNode.rpc 'getblock', identifier
        Block.new data
      end

      # Returns the hash value of the corresponding block based on the specified index
      #
      # @param index [Integer] index of block to get
      # @return [String]
      def hash(index)
        RemoteNode.rpc 'getblockhash', index
      end
    end
  end
end
