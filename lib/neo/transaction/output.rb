# frozen_string_literal: true

module Neo
  class Transaction
    # Represents a transaction output on the Neo blockchain.
    class Output
      attr_accessor :asset_id, :script_hash, :index
      attr_writer :value

      alias n= index=
      alias asset= asset_id=

      def address
        @address || Key.script_hash_to_address(@script_hash)
      end

      def address=(address)
        @script_hash = Key.address_to_script_hash(address)
        @address = address
      end

      def value
        @value.to_i
      end

      class << self
        # Returns the corresponding transaction output (change) information based on the specified hash and index
        #
        # @param txid [String] transaction ID
        # @param index [Integer] The index of the transaction output to be obtained in the transaction (starts from 0)
        # @return [Neo::Transaction::Output]
        def get(txid, index)
          data = RemoteNode.rpc 'gettxout', txid, index
          data.each_with_object(Output.new) do |(k, v), output|
            output.send("#{k}=", v)
          end
        end
      end
    end
  end
end
