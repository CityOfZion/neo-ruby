# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class ExecutionEngine
        class << self
          # Get the script container for this smart contract (the first trigger)
          def get_script_container(*params); raise('Stub or mock required.') end

          # Get the scripthash of the executing smart contract
          def get_executing_script_hash(*params); raise('Stub or mock required.') end

          # Get the scripthash of the caller for this smart contract
          def get_calling_script_hash(*params); raise('Stub or mock required.') end

          # Get the scripthash of the entry point for the smart contract (the starting point of the contract call chain)
          def get_entry_script_hash(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
