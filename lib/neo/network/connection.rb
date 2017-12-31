module Neo
  module Network
    class Connection < EventMachine::Connection
      include Neo::Network::Handler

      def initialize(host, port, last_hash)
        @host = host
        @port = port
        @last_hash = last_hash
        @parser = Parser.new(self)
        @node_id = rand(0xffffffffffffffff)
      end

      def post_init
        log 'connected', [@host, @port].join(':')
      end

      def receive_data(data)
        @parser.buffer data
      end

      def unbind
        log 'disconnected', @host
        Connection.connect_to_random_node(@last_hash)
      end

      def send_packet(message)
        log message.command, message.inspect, false
        send_data message.packet
      end

      def log(*args)
        self.class.log(*args)
      end

      class << self
        def connect(host, port, last_hash)
          EM.connect(host, port, self, host, port, last_hash)
        end

        def connect_to_random_node(last_hash = nil)
          host, port = Neo.config.p2p_nodes.to_a.sample.split(':')
          connect(host, port, last_hash)
        end

        # TODO: Refactor this crap.
        def log(event, message = nil, inbound = true)
          if message
            puts "#{inbound ? '<' : '>'} [#{event}] #{message}"
          else
            puts "#{inbound ? '<' : '>'} #{event}"
          end
        end
      end
    end
  end
end
