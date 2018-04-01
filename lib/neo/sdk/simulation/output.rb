# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Output
        class << self
          # Get Asset ID
          def get_asset_id(*params); raise('Stub or mock required.') end

          # Get the transaction amount
          def get_script_hash(*params); raise('Stub or mock required.') end

          # Get Script Hash
          def get_value(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
