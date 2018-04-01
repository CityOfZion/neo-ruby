# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Enrollment
        class << self
          # Deprecated Replaced with Neo.Blockchain.Get_Validators
          def get_public_key(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
