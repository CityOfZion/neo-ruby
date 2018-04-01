# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Validator
        class << self
          # Register as a bookkeeper
          def register(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
