module Neo
  module Network
    module Handler
      def handle_version(payload)
        version = VersionPayload.read payload
        send_packet VersionPayload.new(@port, @local_node.node_id, version.start_height)
      end

      def handle_verack(_payload)
        send_packet VerackPayload.new
        @callbacks[:connected].each(&:call)
      end

      def handle_inv(payload)
        inv = InvPayload.read payload
        puts inv.inspect
      end

      def handle_block(payload)
        @callbacks[:block].each { |c| c.call payload }
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name =~ /^handle_/ || super
      end

      private

      def method_missing(method_name, *_arguments)
        if method_name =~ /^handle_/
          log method_name, 'Not implemented'
        else
          super
        end
      end
    end
  end
end
