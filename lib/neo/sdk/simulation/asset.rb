# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Asset
        class << self
          #  Register a new asset
          def create(*params); raise('Stub or mock required.') end

          # Obtain the administrator (contract address) of the asset
          def get_admin(*params); raise('Stub or mock required.') end

          # Get the total amount of the asset
          def get_amount(*params); raise('Stub or mock required.') end

          # Get ID of the asset
          def get_asset_id(*params); raise('Stub or mock required.') end

          # Get the category of the asset
          def get_asset_type(*params); raise('Stub or mock required.') end

          # Get the quantity of the asset that has been issued
          def get_available(*params); raise('Stub or mock required.') end

          # Obtain the issuer (contract address) of the asset
          def get_issuer(*params); raise('Stub or mock required.') end

          # Get the owner of the asset (public key)
          def get_owner(*params); raise('Stub or mock required.') end

          # Get the number of divisions for this asset, the number of digits after the decimal point
          def get_precision(*params); raise('Stub or mock required.') end

          #  Renew an asset
          def renew(years)(*params); raise('Stub or mock required.') end
        end
      end
    end
  end
end
