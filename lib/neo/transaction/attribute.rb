module Neo
  class Transaction
    class Attribute
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

      def initialize(usage, data)
        @usage = usage

        case usage
        when CONTRACT_HASH, ECDH02, ECDH03, VOTE, HASH
          @data = data.read_hex(32)
        when SCRIPT
          @data = data.read_hex(20)
        else
          @data = data.read_hex
        end
      end
    end
  end
end
