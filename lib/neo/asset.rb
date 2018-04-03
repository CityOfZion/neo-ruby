require 'neo/utils/entity'

module Neo
  # Represents an asset on the Neo blockchain
  class Asset
    include Neo::Utils::Entity

    GAS_ID = 0x602c79718b16e442de58778e148d0b1084e3b2dffd5de6b7b16cee7969282de7
    NEO_ID = 0xc56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b

    attr_accessor :version, :id, :type, :amount, :available, :precision, :owner, :admin, :issuer, :expiration, :frozen

    def name(lang = 'en')
      @names[lang]
    end

    def name=(names)
      @names = names.each_with_object({}) { |name, memo| memo[name['lang']] = name['name'] }
    end

    class << self
      def neo
        data = RemoteNode.rpc 'getassetstate', NEO_ID.to_s(16)
        new(**(data.each_with_object({}) { |(k,v), h| h[k.to_sym] = v }))
      end

      def gas
        data = RemoteNode.rpc 'getassetstate', GAS_ID.to_s(16)
        new(**(data.each_with_object({}) { |(k,v), h| h[k.to_sym] = v }))
      end
    end
  end
end
