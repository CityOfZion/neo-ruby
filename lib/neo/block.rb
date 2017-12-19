require 'neo/key'
require 'neo/utils'

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
                :next_consensus

    alias consensus_data nonce

    # Construct a new block from given data
    # @param data [Hash] Ruby hash of parsed JSON format block data
    def initialize(data = nil)
      @data = StringIO.new [data].pack('H*')
      parse_header
    end

    def parse_header
      @version, * = data.read(4).unpack('V')
      @previous_block_hash = Utils.bin_to_hex(data.read(32))
      @merkle_root = Utils.bin_to_hex(data.read(32))
      @time_stamp, * = data.read(4).unpack('V')
      @height, * = data.read(4).unpack('V')
      @nonce = Utils.bin_to_hex(data.read(8))
      @next_consensus = Key.script_hash_to_address(data.read(20).unpack('H*').first)
      data.read(1)
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
