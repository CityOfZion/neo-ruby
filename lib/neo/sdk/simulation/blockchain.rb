# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests.
      class Blockchain
        class << self
          # Get an account based on the scripthash of the contract
          def get_account(*params); raise('Stub or mock required.') end

          # Get asset based on asset ID
          def get_asset(*params); raise('Stub or mock required.') end

          # Find block by block Height or block Hash
          def get_block(*params); raise('Stub or mock required.') end

          # New Get contract content based on contract hash
          def get_contract(*params); raise('Stub or mock required.') end

          # Find block header by block height or block hash
          def get_header(*params); raise('Stub or mock required.') end

          # Get the current block height
          def get_height(*params); raise('Stub or mock required.') end

          # Find transaction via transaction ID
          def get_transaction(*params); raise('Stub or mock required.') end

          # Get the public key of the consensus node
          def get_validators(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
