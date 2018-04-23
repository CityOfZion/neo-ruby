# frozen_string_literal: true

module Neo
  module Network
    module Handler
      def handle_version(payload)
        version = VersionPayload.read payload
        send_packet VerackPayload.new
      end

      def handle_verack(_payload)
        @callbacks[:connected].each(&:call)
      end

      def handle_inv(payload)
        inv = InvPayload.read payload
        case inv.type
        when :block
          hashes = Set.new inv.hashes
          unknown_hashes = hashes - @local_node.known_hashes
          enqueue_message InvPayload.new(:block, unknown_hashes, 'getdata') unless unknown_hashes.length.zero?
        else
          puts inv.inspect
        end
      end

      def handle_block(payload)
        block_payload = BlockPayload.read payload
        block_payload.block.store
        @callbacks[:block].each { |c| c.call block_payload.block }
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name =~ /^handle_/ || super
      end

      private

      def method_missing(method_name, *_arguments)
        if method_name.match?(/^handle_/)
          log method_name, 'Not implemented'
        else
          super
        end
      end
    end
  end
end
