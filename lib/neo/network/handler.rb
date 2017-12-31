module Neo
  module Network
    module Handler
      def on_version(payload)
        version = VersionPayload.read payload
        send_packet :version, VersionPayload.new(@port, @node_id, version.start_height).write
      end

      def on_verack(_payload)
        send_packet :verack
        EM.schedule { request_blocks }
      end

      def on_inv(payload)
        puts "inv: #{payload}"
      end

      def on_headers(payload)
        puts "headers: #{payload}"
      end

      def on_block(payload)
        puts "block: #{payload}"
      end

      def request_blocks
        send_packet :getblocks, LocatorPayload.new([@last_hash]).write
      end

      private

      def send_packet(command, payload = '')
        checksum = Digest::SHA256.digest(Digest::SHA256.digest(payload))[0...4]
        header = [
          Neo.config.magic_word,
          command.to_s,
          payload.bytesize,
          checksum
        ].pack 'a4a12Va4'

        send_data header + payload
      end
    end
  end
end
