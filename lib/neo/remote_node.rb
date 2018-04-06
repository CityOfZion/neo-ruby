# frozen_string_literal: true

require 'net/http'
require 'json'

module Neo
  # Represents a remote node on the Neo network. Primarily used for RPC function calls.
  class RemoteNode
    attr_reader :url, :port, :nonce, :user_agent

    def initialize(url)
      @url = url
      @useragent = nil
    end

    # Get version information of this node
    # TODO: Probably refactor this.
    def version
      unless @useragent
        data = rpc 'getversion'
        @port = data['port']
        @nonce = data['nonce']
        @user_agent = data['useragent']
      end
      @user_agent
    end

    # Gets the current number of connections for the node
    def connection_count
      rpc 'getconnectioncount'
    end

    # Get a list of nodes that are currently connected/disconnected by this node
    def peers
      rpc 'getpeers'
    end

    # Get a list of unconfirmed transactions in memory
    def mempool
      rpc 'getrawmempool'
    end

    # Make a call to the node's JSON-RPC interface
    #
    # @param method [String] The RPC method name to call
    # @param params [Array<String>] arguments to the RPC method
    # @return [Hash] The parsed JSON response
    def rpc(method, *params)
      uri = URI @url
      options = { jsonrpc: '2.0', method: method, params: params.to_s, id: 1 }
      uri.query = URI.encode_www_form options
      response = Net::HTTP.get uri
      JSON.parse(response)['result']
    end

    class << self
      def random
        new Neo.config.rpc_nodes.to_a.sample
      end

      # Select a random node and get the mem pool
      def mempool
        random.mempool
      end

      def rpc(method, *params)
        random.rpc method, *params
      end
    end
  end
end
