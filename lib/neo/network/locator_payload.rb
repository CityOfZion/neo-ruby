# frozen_string_literal: true

module Neo
  module Network
    class LocatorPayload < Message
      attr_accessor :hashes, :stop

      def initialize(hashes = [], stop = nil, command = 'getblocks')
        @hashes = hashes
        @stop = stop || '00' * 32
        @command = command
      end

      def deserialize(data)
        count = data.read_vint
        count.times do
          @hashes << data.read_hex(32, true)
        end
        @stop = data.read_hex 32, true
      end

      def serialize(data)
        data.write_vint hashes.length
        hashes.each do |hash|
          data.write_hex hash, true, true
        end
        data.write_hex stop, true, true
      end
    end
  end
end
