# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Contract
        class << self
          #  Publish a smart contract
          def create(*params); raise('Stub or mock required.') end

          #  Destroy a smart contract
          def destroy(*params); raise('Stub or mock required.') end

          # Get the scripthash of the contract
          def get_script(*params); raise('Stub or mock required.') end

          #  Get the storage context of the contract
          def get_storage_context(*params); raise('Stub or mock required.') end

          #  Migrate/Renew a smart contract
          def migrate(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
