# frozen_string_literal: true

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
        @message_queue = EM::Queue.new

        on_connected do
          @local_node.add_connection self
          EM.add_periodic_timer(1) { process_message_queue }
          EM.add_periodic_timer(20) { request_blocks }
          EM.next_tick { request_blocks }
        end

        on_block do |block|
          @local_node.last_height = block.height
          @local_node.last_hash = block.block_hash

          log 'block', block.height
        end
      end

      def process_message_queue
        @message_queue.pop do |message|
          send_packet message
        end
      end

      def enqueue_message(message)
        @message_queue.push message
      end

      def request_blocks
        enqueue_message LocatorPayload.new([@local_node.last_hash])
      end

      def send_packet(message)
        # log message.command, message.inspect, false
        # data = message.packet
        # log 'raw', data.unpack('H*').first, false
        send_data message.packet
      end

      def log(*args)
        self.class.log(*args)
      end

      def post_init
        log "Connecting to #{@host} on #{@port}."
        EM.next_tick do
          send_packet VersionPayload.new(@port, @local_node.node_id, @local_node.last_height)
        end
      end

      def receive_data(data)
        # log 'raw', data.unpack('H*').first
        @parser.buffer data
      end

      def unbind
        log "Disconnected from #{@host}."
        @local_node.remove_connection self
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
            puts "#{inbound ? '>>>' : '<<<'} [#{event}] #{message}"
          else
            puts event
          end
        end
      end
    end
  end
end
