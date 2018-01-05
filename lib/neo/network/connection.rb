module Neo
  module Network
    class Connection < EventMachine::Connection
      include Neo::Network::Handler
      include Neo::Network::Events

      def initialize(host, port, local_node)
        @host = host
        @port = port
        @parser = Parser.new self
        @local_node = local_node
        @callbacks = {
          connected: [],
          disconnected: [],
          block: []
        }

        on_connected do
          @local_node.add_connection self
          EM.add_periodic_timer(20) { request_blocks }
        end

        on_block do |_block|
          log 'block', 'Recieving a block'
          # TODO: Update @last_hash
        end
      end

      def request_blocks
        send_packet LocatorPayload.new([@local_node.last_hash])
      end

      def send_packet(message)
        log message.command, message.inspect, false
        data = message.packet
        log 'raw', data.unpack('H*').first, false
        send_data message.packet
      end

      def log(*args)
        self.class.log(*args)
      end

      # TODO: move to Handler?
      def post_init
        log "Connecting to #{@host} on #{@port}."
      end

      # TODO: move to Handler?
      def receive_data(data)
        log 'raw', data.unpack('H*').first
        @parser.buffer data
      end

      # TODO: move to Handler?
      def unbind
        log "Disconnected from #{@host}."
        Connection.connect_to_random_node @local_node
      end

      class << self
        def connect(host, port, local_node)
          EM.connect host, port, self, host, port, local_node
        end

        def connect_to_random_node(local_node)
          host, port = Neo.config.p2p_nodes.to_a.sample.split(':')
          connect host, port, local_node
        end

        # TODO: Refactor this crap.
        def log(event, message = nil, inbound = true)
          if message
            puts "#{inbound ? '<' : '>'} [#{event}] #{message}"
          else
            event
          end
        end
      end
    end
  end
end
