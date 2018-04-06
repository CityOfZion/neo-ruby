# frozen_string_literal: true

module Neo
  # Represent a smart contract on the Neo blockchain
  class Contract
    attr_accessor :version,
                  :hash,
                  :script,
                  :parameters,
                  :return_type,
                  :storage,
                  :name,
                  :code_version,
                  :author,
                  :email,
                  :description

    alias returntype= return_type=

    class << self
      def get(script_hash)
        data = RemoteNode.rpc 'getcontractstate', script_hash
        contract = Contract.new
        data.each { |k, v| contract.send "#{k}=", v }
        contract
      end

      def storage(script_hash, key)
        RemoteNode.rpc 'getstorage', script_hash, key
      end
    end
  end
end
