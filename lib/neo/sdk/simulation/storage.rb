# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A module meant for mocking and stubbing in your tests
      module Storage
        class << self
          # Deletes a value from the persistent store based off the given key
          def delete(*params); raise('Stub or mock required.') end

          # Returns the value in the persistent store based off the key given
          def get(*params); raise('Stub or mock required.') end

          # Get the current store context
          def get_context(*params); raise('Stub or mock required.') end

          # Inserts a value into the persistent store based off the given key
          def put(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
