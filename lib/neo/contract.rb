require 'neo/utils/entity'

module Neo
  # Represent a smart contract on the Neo blockchain
  class Contract
    include Neo::Utils::Entity

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
        new(**(data.each_with_object({}) { |(k,v), h| h[k.to_sym] = v }))
      end

      def storage(script_hash, key)
        RemoteNode.rpc 'getstorage', script_hash, key
      end
    end
  end
end
