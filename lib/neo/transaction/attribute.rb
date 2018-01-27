require 'neo/utils/entity'

module Neo
  class Transaction
    class Attribute
      include Neo::Utils::Entity

      CONTRACT_HASH = 0x00
      ECDH02 = 0x02
      ECDH03 = 0x03
      SCRIPT = 0x20
      VOTE = 0x30
      CERT_URL = 0x80
      DESCRIPTION_URL = 0x81
      DESCRIPTION = 0x90
      HASH = 0xa1..0xaf
      REMARK = 0xf0..0xff

      attr_reader :usage, :data

      class << self
        def read(data)
          attrs = {usage: data.read_uint8}
          attrs[:data] = case attrs[:usage]
                         when CONTRACT_HASH, ECDH02, ECDH03, VOTE, HASH
                           data.read_hex(32)
                         when SCRIPT
                           data.read_hex(20)
                         else
                           data.read_hex
                         end
          new(**attrs)
        end
      end
    end
  end
end
