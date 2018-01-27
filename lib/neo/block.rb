require 'neo/utils/entity'

module Neo
  # Represents a block in the Neo blockchain
  class Block
    include Neo::Utils::Entity

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

    def initialize(attrs = {})
      super
      @transactions = [] if @transactions.nil?
    end

    def serialize_header(data)
      data.write_uint32 @version
      data.write_hex @previous_block_hash, true, true
      data.write_hex @merkle_root, true, true
      data.write_uint32 @time_stamp
      data.write_uint32 @height
      data.write_hex @nonce, true, true
      data.write_hex Key.address_to_script_hash(@next_consensus), true
    end

    # TODO: This.
    def serialize_body(data)
      data.write_byte 1
      # @script.serialize(data)
      data.write_vint @transactions.size
      @transactions.each do |tx|
        # tx.serialize(data)
      end
    end

    def serialize(data)
      serialize_header data
      serialize_body data
    end

    # Hash the contents of this block
    #
    # @return [String]
    def block_hash
      data = Utils::DataWriter.new
      serialize_header data
      hash1 = Digest::SHA256.digest(data.io.string)
      hash2 = Digest::SHA256.hexdigest(hash1)
      Utils.reverse_hex_string(hash2)
    end

    class << self

      # Parse a block from raw data
      #
      # @param data [Utils::DataReader] binary data to parse
      # @return [Neo::Block]
      def read(data)
        attrs = {
          version: data.read_uint32,
          previous_block_hash: data.read_hex(32, true),
          merkle_root: data.read_hex(32, true),
          time_stamp: data.read_uint32,
          height: data.read_uint32,
          nonce: data.read_hex(8, true),
          next_consensus: Key.script_hash_to_address(data.read_hex(20)),
        }

        data.read_byte

        attrs[:script] = Script.read(data)
        attrs[:transactions] = Array.new(data.read_vint) do
          Transaction.read(data)
        end

        Block.new(**attrs)
      end

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
        Block.read Utils::DataReader.new(data)
      end

      # Returns the hash value of the corresponding block based on the specified index
      #
      # @param index [Integer] index of block
      # @return [String]
      def hash(index)
        RemoteNode.rpc 'getblockhash', index
      end

      # Returns the system fees before the block according to the specified index
      #
      # @param index [Integer] index of block
      # @return [Integer]
      def sys_fee(index)
        RemoteNode.rpc('getblocksysfee', index).to_i
      end
    end
  end
end
