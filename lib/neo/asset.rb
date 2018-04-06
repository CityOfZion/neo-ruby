# frozen_string_literal: true

module Neo
  # Represents an asset on the Neo blockchain
  class Asset
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
        create RemoteNode.rpc('getassetstate', NEO_ID.to_s(16))
      end

      def gas
        create RemoteNode.rpc('getassetstate', GAS_ID.to_s(16))
      end

      def create(data)
        asset = Asset.new
        data.each { |k, v| asset.send "#{k}=", v }
        asset
      end
    end
  end
end
