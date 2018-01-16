module Neo
  class Transaction
    # Represents a transaction input on the Neo blockchain.
    class Input
      attr_accessor :previous_hash, :previous_index

      def initialize(previous_hash = nil, previous_index = nil)
        self.previous_hash = previous_hash
        self.previous_index = previous_index
      end
    end
  end
end
