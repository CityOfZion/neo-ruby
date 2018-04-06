# frozen_string_literal: true

module Neo
  module Network
    class InvPayload < Message
      TYPES = {
        0x01 => :transaction,
        0x02 => :block,
        0xe0 => :consensus
      }.freeze

      attr_accessor :type, :hashes

      def initialize(type = nil, hashes = [], command = 'inv')
        @type = type
        @hashes = Array(hashes)
        @command = command
      end

      def deserialize(data)
        @type = TYPES[data.read_byte]
        count = data.read_vint
        count.times do
          @hashes << data.read_hex(32, true)
        end
      end

      def serialize(data)
        data.write_byte TYPES.key type
        data.write_vint hashes.length
        hashes.each do |hash|
          data.write_hex hash, true, true
        end
      end
    end
  end
end
