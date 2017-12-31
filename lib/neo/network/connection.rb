module Neo
  module Network
    class Connection < EventMachine::Connection
      include Neo::Network::Handler

      # TODO: Move this to Neo.config
      SEED_LIST = [
        ['seed1.neo.org', 20_333],
        ['seed2.neo.org', 20_333],
        ['seed3.neo.org', 20_333],
        ['seed4.neo.org', 20_333],
        ['seed5.neo.org', 20_333]
      ].freeze

      def initialize(host, port, connections, last_hash)
        @host = host
        @port = port
        @last_hash = last_hash
        @connections = connections
        @parser = Parser.new(self)
        @node_id = rand(0xffffffffffffffff)
      end

      def post_init
        log 'connected', @host
      end

      def receive_data(data)
        log 'data', data
        @parser.buffer data
      end

      def unbind
        log 'disconnected', @host
        Connection.connect_to_random_node(@connections)
      end

      def log(*args)
        self.class.log(*args)
      end

      class << self
        def connect(host, port, connections, last_hash)
          EM.connect(host, port, self, host, port, connections, last_hash)
        end

        def connect_to_random_node(connections, last_hash = '00' * 32)
          host, port = *SEED_LIST.sample
          connect(host, port, connections, last_hash)
        end

        def log(event, message = nil)
          if message
            puts "> [#{event}] #{message}"
          else
            puts event
          end
        end
      end
    end
  end
end
