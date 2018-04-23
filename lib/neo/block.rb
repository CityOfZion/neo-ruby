# frozen_string_literal: true

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
    def initialize
      @transactions = []
    end

    # NOTE: Possible refactor might be to use instance variable / attribute for `data` and not pass it around as a
    # parameter to the parsing / serialization methods.
    def read(data)
      @data = data
      parse_header data
      parse_body data
      self
    end

    def parse_header(data)
      @version = data.read_uint32
      @previous_block_hash = data.read_hex 32, true
      @merkle_root = data.read_hex 32, true
      @time_stamp = data.read_uint32
      @height = data.read_uint32
      @nonce = data.read_hex 8, true
      @next_consensus = Key.script_hash_to_address data.read_hex(20)
    end

    def parse_body(data)
      data.read_byte
      @script = Script.read data
      transaction_count = data.read_vint
      transaction_count.times do
        @transactions << Transaction.read(data)
      end
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

    # Persist the block to storage
    # TODO: Refactor SDBM calls to a DB class that provides simple
    # (replaceable?) API that can be used throughout the library.
    def store
      SDBM.open File.join(Neo.config.db_path, 'block') do |db|
        db[block_hash] = data.io.string
      end
    end

    class << self
      # Parse a block from raw data
      #
      # @param data [Utils::DataReader] binary data to parse
      # @return [Neo::Block]
      def read(data)
        block = Block.new
        block.read(data)
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
