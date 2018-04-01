# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Attribute
        class << self
          # Get extra data outside of the purpose of transaction
          def get_data(*params); raise('Stub or mock required.') end

          # Get purpose of transaction
          def get_usage(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
