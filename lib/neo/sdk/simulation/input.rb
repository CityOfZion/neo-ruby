# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Input
        class << self
          # Get the hash of the referenced previous transaction
          def get_hash(*params); raise('Stub or mock required.') end

          # The index of the input in the output list of the referenced previous transaction
          def get_index(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
