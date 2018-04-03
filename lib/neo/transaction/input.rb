require 'neo/utils/entity'

module Neo
  class Transaction
    # Represents a transaction input on the Neo blockchain.
    class Input
      include Neo::Utils::Entity

      attr_accessor :previous_hash, :previous_index
    end
  end
end
