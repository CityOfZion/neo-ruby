module Neo
  class Node
    attr_reader :known_hashes, :node_id
    attr_accessor :last_hash

    def initialize(starting_hash = nil)
      @connections = []
      @known_hashes = Set.new
      @last_hash = starting_hash
      @node_id = rand 0xffffffffffffffff

      Neo::Network::Connection.connect_to_random_node self
    end

    def add_connection(connection)
      @connections << connection
    end

    class << self
      def start
        EM.run do
          new Neo::Block.best_hash
        end
      end
    end
  end
end
