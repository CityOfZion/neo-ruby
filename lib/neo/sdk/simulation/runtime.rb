# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A module meant for mocking and stubbing in your tests
      module Runtime
        class << self
          #  Verifies that the calling contract has verified the required script hashes of the transaction/block
          def check_witness(*params); raise('Stub or mock required.') end

          #  Notifies the client with a log message during smart contract execution
          def log(*params); raise('Stub or mock required.') end

          #  Notifies the client with a notification during smart contract execution
          def notify(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
