module Neo
  module Network
    module Handler
      def on_version(payload)
        version = VersionPayload.read payload
        send_packet VersionPayload.new(@port, @node_id, version.start_height)
      end

      def on_verack(_payload)
        send_packet VerackPayload.new
        EM.schedule { request_blocks }
      end

      def on_getblocks(payload)
        locator = LocatorPayload.read payload
        log 'getblocks', locator.inspect
      end

      def on_block(payload)
        puts "block: #{payload}"
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name =~ /^on_/ || super
      end

      protected

      def request_blocks
        send_packet LocatorPayload.new([@last_hash])
      end

      private

      def method_missing(method_name, *_arguments)
        if method_name =~ /^on_/
          log method_name, 'Not implemented'
        else
          super
        end
      end
    end
  end
end
