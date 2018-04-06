# frozen_string_literal: true

require 'openssl'

module Neo
  # Represents a Neo private/public key pair
  class Key
    DEFAULT_ADDRESS_VERSION = '17'
    PUSHBYTES33 = '21'
    CHECKSIG = 'ac'
    WIF_PREFIX = '80' # MainNet
    WIF_SUFFIX = '01' # Compressed

    def initialize(address_version = DEFAULT_ADDRESS_VERSION)
      @address_version = address_version
      @key = OpenSSL::PKey::EC.new('prime256v1').generate_key
    end

    def private_hex
      @key.private_key.to_s(16).downcase
    end

    def public_key_encoded
      @key.public_key.to_bn(:compressed).to_s(16).downcase
    end

    def script
      PUSHBYTES33 + public_key_encoded + CHECKSIG
    end

    def script_hash
      bytes = [script].pack('H*')
      sha256 = Digest::SHA256.digest(bytes)
      Digest::RMD160.hexdigest(sha256)
    end

    def address
      Key.script_hash_to_address(script_hash, @address_version)
    end

    def wif
      Key.private_key_to_wif(private_hex)
    end

    class << self
      def script_hash_to_address(script_hash, address_version = DEFAULT_ADDRESS_VERSION)
        Utils::Base58.encode(with_checksum(address_version + script_hash).to_i(16))
      end

      # TODO: verify checksum
      def address_to_script_hash(address)
        Neo::Utils::Base58.decode(address).to_s(16)[2...42]
      end

      def private_key_to_wif(private_key)
        Utils::Base58.encode(with_checksum(WIF_PREFIX + private_key + WIF_SUFFIX).to_i(16))
      end

      def with_checksum(hex)
        bytes = [hex].pack('H*')
        hash1 = Digest::SHA256.digest(bytes)
        hash2 = Digest::SHA256.hexdigest(hash1)
        hex + hash2.slice(0, 8)
      end
    end
  end
end
