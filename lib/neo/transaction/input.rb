# frozen_string_literal: true

module Neo
  class Transaction
    # Represents a transaction input on the Neo blockchain.
    class Input
      attr_accessor :previous_hash, :previous_index
    end
  end
end
