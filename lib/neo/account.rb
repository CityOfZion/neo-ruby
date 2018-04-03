require 'neo/utils/entity'

module Neo
  # Represents an account on the Neo Blockchain
  class Account
    include Neo::Utils::Entity

    attr_accessor :version, :script_hash, :frozen, :votes, :balances

    def neo_balance
      balance = @balances.find { |b| b['asset'] == '0x' + Asset::NEO_ID.to_s(16) }
      balance ? balance['value'].to_i : 0
    end

    def gas_balance
      balance = @balances.find { |b| b['asset'] == '0x' + Asset::GAS_ID.to_s(16) }
      balance ? balance['value'].to_f : 0
    end

    class << self

      def get(address)
        data = RemoteNode.rpc 'getaccountstate', address
        new(**(data.each_with_object({}) { |(k,v), h| h[k.to_sym] = v }))
      end

      # Verify that the address is a correct NEO address
      #
      # @param address [String] Address to validate
      # @return [Boolean]
      def validate(address)
        response = RemoteNode.rpc 'validateaddress', address
        response['isvalid']
      end
    end
  end
end
