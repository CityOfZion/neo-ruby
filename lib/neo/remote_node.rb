require 'net/http'
require 'json'

module Neo
  class RemoteNode
    attr_reader :url

    def initialize(url)
      @url = url
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

      def rpc(method, *params)
        random.rpc method, *params
      end
    end
  end
end
