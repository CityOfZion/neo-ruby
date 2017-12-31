module Neo
  module Network
    class LocatorPayload < Payload
      attr_accessor :hashes, :stop

      def initialize(hashes = [], stop = nil)
        @hashes = hashes
        @stop = stop
      end

      # TODO: deserialize this.
      def deserialize(data); end

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
