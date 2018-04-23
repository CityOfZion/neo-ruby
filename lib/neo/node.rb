# frozen_string_literal: true

require 'eventmachine'

module Neo
  class Node
    attr_reader :known_hashes, :node_id
    attr_accessor :last_hash, :last_height

    def initialize(starting_hash = nil, starting_height = 0)
      @connections = []
      @known_hashes = Set.new
      @last_hash = starting_hash
      @last_height = starting_height
      @node_id = rand 0xffffffffffffffff

      Neo::Network::Connection.connect_to_random_node self
    end

    def add_connection(connection)
      @connections << connection
    end

    # TODO: Test this.
    def remove_connection(connection)
      @connections.delete connection
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
