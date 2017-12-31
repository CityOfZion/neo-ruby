module Neo
  module Network
    class LocatorPayload < Message
      attr_accessor :hashes, :stop

      def initialize(hashes = [], stop = nil, command = 'getblocks')
        @hashes = hashes
        @stop = stop
        @command = command
      end

      def deserialize(data)
        count = data.read_vint
        count.times do
          @hashes << data.read_hex(32)
        end
        @stop = data.read_hex(32)
      end

      def serialize(data)
        data.write_vint hashes.length
        hashes.each do |hash|
          data.write_hex hash, true, true
        end
        data.write_hex stop, true, true if stop
      end
    end
  end
end
